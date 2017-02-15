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
