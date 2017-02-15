--
-- CreatorTools
--
-- @author  TyKonKet
-- @date 15/02/2017

function margeI18N()
    for k,v in pairs(g_i18n.texts) do
        g_i18n.globalI18N:setText(k, v);
    end
end

function parseI18N()
    for k,v in pairs(g_i18n.texts) do
        local nv = v;
        for m in nv:gmatch("$input_.-;") do
            local input = m:gsub("$input_", ""):gsub(";", "");
            nv = nv:gsub(m, InputBinding.getKeysNamesOfDigitalAction(InputBinding[input]));
        end
        g_i18n.texts[k] = nv;
    end
end
