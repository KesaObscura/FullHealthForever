local _, ns = ...

-- Every text the addon shows itself. Technical output of /fhf probe stays English on purpose
-- (bug reports), like /fmf probe in Full Mana Forever.
local strings = {}

strings.enUS = {
  helpHead   = "Full Health Forever %s (test build). Commands:",
  helpProbe  = "/fhf probe - snapshot: what an addon can read about health",
  helpWatch  = "/fhf probe watch [seconds] - events and a test frame on screen (30 s by default)",
  helpStop   = "/fhf probe stop - stop the watch early",
  helpSend   = "Results are also saved: /reload, then send WTF\\Account\\<account>\\SavedVariables\\FullHealthForever.lua",
  unknown    = "Unknown command. Type /fhf for help.",
  watchStart = "Probe watch: %d s. Fight, get healed, drink a potion, use a bandage.",
  watchDone  = "Probe watch done. Lines saved; /reload writes the file.",
  snapDone   = "Snapshot done. Take it once out of combat and once in combat.",
}

strings.deDE = {
  helpHead   = "Full Health Forever %s (Testversion). Befehle:",
  helpProbe  = "/fhf probe - Momentaufnahme: was ein Addon über die Gesundheit lesen kann",
  helpWatch  = "/fhf probe watch [Sekunden] - Ereignisse und ein Testfenster auf dem Bildschirm (standardmäßig 30 s)",
  helpStop   = "/fhf probe stop - Beobachtung vorzeitig beenden",
  helpSend   = "Die Ergebnisse werden auch gespeichert: /reload, dann schick WTF\\Account\\<Account>\\SavedVariables\\FullHealthForever.lua",
  unknown    = "Unbekannter Befehl. Gib /fhf für die Hilfe ein.",
  watchStart = "Beobachtung: %d s. Kämpfe, lass dich heilen, trink einen Trank, benutz einen Verband.",
  watchDone  = "Beobachtung beendet. Zeilen gespeichert; /reload schreibt die Datei.",
  snapDone   = "Momentaufnahme fertig. Mach sie einmal außerhalb und einmal im Kampf.",
}

strings.ruRU = {
  helpHead   = "Full Health Forever %s (тестовая сборка). Команды:",
  helpProbe  = "/fhf probe - снимок: что аддон может прочитать о здоровье",
  helpWatch  = "/fhf probe watch [секунды] - события и тестовое окно на экране (по умолчанию 30 с)",
  helpStop   = "/fhf probe stop - остановить наблюдение раньше",
  helpSend   = "Результаты сохраняются: /reload, потом пришли WTF\\Account\\<аккаунт>\\SavedVariables\\FullHealthForever.lua",
  unknown    = "Неизвестная команда. Набери /fhf для справки.",
  watchStart = "Наблюдение: %d с. Сражайся, получи хил, выпей зелье, наложи бинт.",
  watchDone  = "Наблюдение закончено. Строки сохранены; /reload запишет файл.",
  snapDone   = "Снимок готов. Сделай его один раз вне боя и один раз в бою.",
}

strings.esES = {
  helpHead   = "Full Health Forever %s (versión de prueba). Comandos:",
  helpProbe  = "/fhf probe - instantánea: lo que un addon puede leer de la salud",
  helpWatch  = "/fhf probe watch [segundos] - eventos y una ventana de prueba en pantalla (30 s por defecto)",
  helpStop   = "/fhf probe stop - terminar la observación antes",
  helpSend   = "Los resultados también se guardan: /reload y luego envía WTF\\Account\\<cuenta>\\SavedVariables\\FullHealthForever.lua",
  unknown    = "Comando desconocido. Escribe /fhf para ver la ayuda.",
  watchStart = "Observación: %d s. Lucha, recibe curaciones, bebe una poción, usa una venda.",
  watchDone  = "Observación terminada. Líneas guardadas; /reload escribe el archivo.",
  snapDone   = "Instantánea lista. Hazla una vez fuera de combate y otra en combate.",
}

-- esMX keeps only its own words; the rest falls back to esES
strings.esMX = setmetatable({}, { __index = strings.esES })

strings.frFR = {
  helpHead   = "Full Health Forever %s (version de test). Commandes :",
  helpProbe  = "/fhf probe - instantané : ce qu'un addon peut lire de la santé",
  helpWatch  = "/fhf probe watch [secondes] - événements et une fenêtre de test à l'écran (30 s par défaut)",
  helpStop   = "/fhf probe stop - arrêter l'observation plus tôt",
  helpSend   = "Les résultats sont aussi enregistrés : /reload, puis envoie WTF\\Account\\<compte>\\SavedVariables\\FullHealthForever.lua",
  unknown    = "Commande inconnue. Tape /fhf pour l'aide.",
  watchStart = "Observation : %d s. Combats, fais-toi soigner, bois une potion, utilise un bandage.",
  watchDone  = "Observation terminée. Lignes enregistrées ; /reload écrit le fichier.",
  snapDone   = "Instantané prêt. Fais-le une fois hors combat et une fois en combat.",
}

strings.ptBR = {
  helpHead   = "Full Health Forever %s (versão de teste). Comandos:",
  helpProbe  = "/fhf probe - retrato: o que um addon consegue ler da vida",
  helpWatch  = "/fhf probe watch [segundos] - eventos e uma janela de teste na tela (30 s por padrão)",
  helpStop   = "/fhf probe stop - parar a observação antes",
  helpSend   = "Os resultados também são salvos: /reload e depois envie WTF\\Account\\<conta>\\SavedVariables\\FullHealthForever.lua",
  unknown    = "Comando desconhecido. Digite /fhf para ajuda.",
  watchStart = "Observação: %d s. Lute, receba cura, beba uma poção, use uma atadura.",
  watchDone  = "Observação concluída. Linhas salvas; /reload grava o arquivo.",
  snapDone   = "Retrato pronto. Faça uma vez fora de combate e uma vez em combate.",
}

strings.koKR = {
  helpHead   = "Full Health Forever %s (테스트 버전). 명령어:",
  helpProbe  = "/fhf probe - 스냅샷: 애드온이 생명력에 대해 읽을 수 있는 것",
  helpWatch  = "/fhf probe watch [초] - 이벤트와 화면의 테스트 창 (기본 30초)",
  helpStop   = "/fhf probe stop - 관찰을 일찍 종료",
  helpSend   = "결과도 저장됩니다: /reload 후 WTF\\Account\\<계정>\\SavedVariables\\FullHealthForever.lua 파일을 보내 주세요",
  unknown    = "알 수 없는 명령어입니다. 도움말은 /fhf 를 입력하세요.",
  watchStart = "관찰: %d초. 전투하고, 치유를 받고, 물약을 마시고, 붕대를 사용하세요.",
  watchDone  = "관찰 완료. 줄이 저장되었습니다. /reload 하면 파일에 기록됩니다.",
  snapDone   = "스냅샷 완료. 전투 밖에서 한 번, 전투 중에 한 번 실행하세요.",
}

strings.zhCN = {
  helpHead   = "Full Health Forever %s（测试版）。命令：",
  helpProbe  = "/fhf probe - 快照：插件能读取哪些生命值信息",
  helpWatch  = "/fhf probe watch [秒] - 事件和屏幕上的测试窗口（默认 30 秒）",
  helpStop   = "/fhf probe stop - 提前停止观察",
  helpSend   = "结果也会保存：/reload 后发送 WTF\\Account\\<账号>\\SavedVariables\\FullHealthForever.lua",
  unknown    = "未知命令。输入 /fhf 查看帮助。",
  watchStart = "观察：%d 秒。战斗、接受治疗、喝药水、使用绷带。",
  watchDone  = "观察结束。记录已保存；/reload 写入文件。",
  snapDone   = "快照完成。请在战斗外和战斗中各做一次。",
}

strings.zhTW = {
  helpHead   = "Full Health Forever %s（測試版）。指令：",
  helpProbe  = "/fhf probe - 快照：插件能讀取哪些生命值資訊",
  helpWatch  = "/fhf probe watch [秒] - 事件和螢幕上的測試視窗（預設 30 秒）",
  helpStop   = "/fhf probe stop - 提前停止觀察",
  helpSend   = "結果也會儲存：/reload 後傳送 WTF\\Account\\<帳號>\\SavedVariables\\FullHealthForever.lua",
  unknown    = "未知指令。輸入 /fhf 查看說明。",
  watchStart = "觀察：%d 秒。戰鬥、接受治療、喝藥水、使用繃帶。",
  watchDone  = "觀察結束。記錄已儲存；/reload 寫入檔案。",
  snapDone   = "快照完成。請在戰鬥外和戰鬥中各做一次。",
}

ns.strings = strings

local ALIASES = { enGB = "enUS", esMX = "esMX" }
local function Resolve(code)
  code = ALIASES[code] or code
  return strings[code] and code or "enUS"
end

ns.lang = Resolve(GetLocale and GetLocale() or "enUS")

ns.L = setmetatable({}, { __index = function(_, k)
  local t = strings[ns.lang]
  return (t and t[k]) or strings.enUS[k]
end })
