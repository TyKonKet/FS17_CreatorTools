const os = require('os');
const gulp = require('gulp');
const gutil = require("gulp-util");
const fs = require("fs");
const path = require('path');
const del = require("del");
const size = require('gulp-size');
const zip = require("gulp-zip");
const run = require('gulp-run');
const replace = require('gulp-replace');
const execFile = require('child_process').execFile;
const ftp = require("vinyl-ftp");

var mod = JSON.parse(fs.readFileSync("mod.json"));
var package = JSON.parse(fs.readFileSync("package.json"));

const modName = mod.name;
const zipName = `${mod.name}.zip`;
const destination = parseAPath(mod.destination);
const zipSources = mod.zipSources;
const start = mod.start;
const fsDocPath = parseAPath(mod.fsDocPath);
const clearLog = mod.clearLog;

const serverUrl = `${mod.server.protocol}://${mod.server.host}:${mod.server.port}/`;

gulp.task("clean:log", () => {
  if (clearLog) {
    return del(`${fsDocPath}log.txt`, { force: true });
  }
  return;
});

gulp.task("clean:out", () => {
  return del(`./out/${zipName}`);
});

gulp.task("clean:install", () => {
  return del(`${destination}${zipName}`, { force: true });
});

gulp.task("startMode", () => {
  return gulp
    .src(`${fsDocPath}game.xml`)
    .pipe(replace(/<startMode>.<\/startMode>/g, "<startMode>1</startMode>"))
    .pipe(gulp.dest(`${fsDocPath}`));
});

gulp.task("build:out", ["clean:out"], () => {
  return gulp.src(zipSources, { cwd: './src/' })
    .pipe(replace(/{package_author}/g, package.author))  
    .pipe(replace(/{package_version}/g, package.version + ".0"))  
    .pipe(size())
    .pipe(zip(zipName))
    .pipe(size())
    .pipe(gulp.dest(`./out/`));
});

gulp.task("install", ["build:out", "clean:install"], () => {
  return gulp.src(`./out/${zipName}`)
    .pipe(gulp.dest(destination));
});

gulp.task("build", ["clean:log", "startMode", "install"], () => {
  if (start.enabled) {
    var params = start.params;
    if (start.savegame.enabled) {
      params.push("-autoStartSavegameId", start.savegame.number);
    }
    return execFile(start.path, params);
  }
  return;
});

gulp.task("release", ["build:out"], () => {
  return;
});

gulp.task("default", ["build"]);

function parseAPath(path) {
  path = path.replace("${homeDir}", os.homedir());
  return path;
}

gulp.task("server:login", serverLogin);

gulp.task("server:stop", ["server:login"], serverStop);

gulp.task("server:start", ["server:login"], serverStart);

gulp.task("server:install:1", ["install", "server:login"], serverStop);

gulp.task("server:install:2", ["server:install:1"], () => {
  const conn = new ftp({
    host: mod.server.ftp.host,
    port: mod.server.ftp.port,
    user: mod.server.ftp.user,
    pass: mod.server.ftp.password
  });
  return gulp
    .src(`./out/${zipName}`, { buffer: false })
    .pipe(conn.dest(mod.server.ftp.path))
    .pipe(gutil.noop());
});

gulp.task("server:install", ["server:install:2"], serverStart);

gulp.task("server:build", ["server:install", "clean:log", "startMode"], () => {
  if (start.enabled) {
    var params = start.params;
    if (start.savegame.enabled) {
      params.push("-autoStartSavegameId", start.savegame.number);
    }
    return execFile(start.path, params);
  }
  return;
});

gulp.task("server:default", ["server:build"]);

function serverLogin() {
  const command = `curl_server_login ${mod.server.username} ${mod.server.password} ${serverUrl}`;//*/`curl -X POST -c .cookies --data "username=${mod.server.username}&password=${mod.server.password}&login=Login" -H "Origin: ${serverUrl}" ${serverUrl}index.html > NUL`;
  return run(command, { silent: true }).exec()
    .pipe(gutil.noop());
}

function serverStop() {
  const command = `curl_server_stop ${serverUrl}`;//*/`curl -X POST -b .cookies --data "stop_server=Stop" -H "Origin: ${serverUrl}" ${serverUrl}index.html > NUL`;
  return run(command, { silent: true }).exec()
    .pipe(gutil.noop());
}

function serverStart() {
  const command = `curl_server_start ${mod.server.game.name} ${mod.server.game.adminPassword} ${mod.server.game.gamePassword} ${mod.server.game.savegame} ${serverUrl}`;//*/`curl -X POST -b .cookies --data "game_name=${mod.server.game.name}&admin_password=${mod.server.game.adminPassword}&game_password=${mod.server.game.gamePassword}&savegame=${mod.server.game.savegame}&map_start=default_Map01&difficulty=1&dirt_interval=2&matchmaking_server=2&mp_language=en&auto_save_interval=180&stats_interval=360&pause_game_if_empty=on&start_server=Start" -H "Origin: ${serverUrl}" ${serverUrl}index.html > NUL`;
  return run(command, { silent: true }).exec()
    .pipe(gutil.noop());
}

gulp.task("translation", () => {

});