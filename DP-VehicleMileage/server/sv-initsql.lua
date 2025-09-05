if Config.AutoRunSQL then
    if not pcall(function()
        local fileName = (Config.Framework == "QBCore" or Config.Framework == "Qbox") and "run-qb.sql" or "run-esx.sql"

        -- Open & read file
        local file = assert(io.open(GetResourcePath(GetCurrentResourceName()) .. "/install/" .. fileName, "rb"))
        local sql = file:read("*all")
        file:close()

        MySQL.query.await(sql)
    end) then
        print(
            "^1[ERROR SQL] Se produjo un error al ejecutar automáticamente el SQL requerido. No se preocupe, solo necesita ejecutar manualmente el archivo SQL de su framework, que se encuentra en la carpeta 'install'. Si ya ha ejecutado el código SQL y este error le molesta, configure Config.AutoRunSQL = false^0")
    end
end
