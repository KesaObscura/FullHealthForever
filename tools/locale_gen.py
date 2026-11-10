# Generates Locale.lua (all texts, 9 languages): python3 tools/locale_gen.py Locale.lua
import sys
KEYS = []
T = {}
def add(key, en, de, ru, es, fr, pt, ko, zhcn, zhtw):
    KEYS.append(key)
    T[key] = dict(enUS=en, deDE=de, ruRU=ru, esES=es, frFR=fr, ptBR=pt, koKR=ko, zhCN=zhcn, zhTW=zhtw)

add("addonName", "Full Health Forever", "Full Health Forever", "Full Health Forever", "Full Health Forever", "Full Health Forever", "Full Health Forever", "Full Health Forever", "Full Health Forever", "Full Health Forever")
add("welcome",
 "Full Health Forever %s: /fhf lists the commands, /fhf config opens the settings.",
 "Full Health Forever %s: /fhf zeigt die Befehle, /fhf config öffnet die Einstellungen.",
 "Full Health Forever %s: /fhf — команды, /fhf config — настройки.",
 "Full Health Forever %s: /fhf muestra los comandos, /fhf config abre los ajustes.",
 "Full Health Forever %s : /fhf affiche les commandes, /fhf config ouvre les réglages.",
 "Full Health Forever %s: /fhf mostra os comandos, /fhf config abre as configurações.",
 "Full Health Forever %s: /fhf 명령어 목록, /fhf config 설정 열기.",
 "Full Health Forever %s：/fhf 查看命令，/fhf config 打开设置。",
 "Full Health Forever %s：/fhf 查看指令，/fhf config 開啟設定。")
add("helpHead", "Full Health Forever %s - commands:", "Full Health Forever %s - Befehle:", "Full Health Forever %s — команды:", "Full Health Forever %s - comandos:", "Full Health Forever %s - commandes :", "Full Health Forever %s - comandos:", "Full Health Forever %s - 명령어:", "Full Health Forever %s - 命令：", "Full Health Forever %s - 指令：")
add("helpConfig", "/fhf config - settings", "/fhf config - Einstellungen", "/fhf config — настройки", "/fhf config - ajustes", "/fhf config - réglages", "/fhf config - configurações", "/fhf config - 설정", "/fhf config - 设置", "/fhf config - 設定")
add("helpLock",
 "/fhf unlock, /fhf lock - move the frame, then lock it",
 "/fhf unlock, /fhf lock - Rahmen verschieben, dann sperren",
 "/fhf unlock, /fhf lock — передвинуть рамку, потом закрепить",
 "/fhf unlock, /fhf lock - mover el marco y luego fijarlo",
 "/fhf unlock, /fhf lock - déplacer le cadre, puis le verrouiller",
 "/fhf unlock, /fhf lock - mover o quadro e depois travá-lo",
 "/fhf unlock, /fhf lock - 프레임을 옮긴 뒤 잠그기",
 "/fhf unlock、/fhf lock - 移动框体，然后锁定",
 "/fhf unlock、/fhf lock - 移動框架，然後鎖定")
add("helpHold",
 "/fhf hold - no hints until the end of the next fight (handy in a macro)",
 "/fhf hold - keine Hinweise bis zum Ende des nächsten Kampfes (praktisch als Makro)",
 "/fhf hold — без подсказок до конца следующего боя (удобно в макросе)",
 "/fhf hold - sin avisos hasta el final del próximo combate (útil en una macro)",
 "/fhf hold - aucun signal jusqu'à la fin du prochain combat (pratique en macro)",
 "/fhf hold - sem avisos até o fim do próximo combate (útil em uma macro)",
 "/fhf hold - 다음 전투가 끝날 때까지 알림 없음 (매크로로 쓰면 편함)",
 "/fhf hold - 下一场战斗结束前不提示（适合做成宏）",
 "/fhf hold - 下一場戰鬥結束前不提示（適合做成巨集）")
add("helpReset",
 "/fhf reset - frame back to its default place",
 "/fhf reset - Rahmen zurück an den Standardplatz",
 "/fhf reset — вернуть рамку на место по умолчанию",
 "/fhf reset - devolver el marco a su sitio por defecto",
 "/fhf reset - remettre le cadre à sa place par défaut",
 "/fhf reset - devolver o quadro ao lugar padrão",
 "/fhf reset - 프레임을 기본 위치로",
 "/fhf reset - 框体回到默认位置",
 "/fhf reset - 框架回到預設位置")
add("helpProfile",
 "/fhf profile own | shared - own profile for this character or the shared one",
 "/fhf profile own | shared - eigenes Profil für diesen Charakter oder das gemeinsame",
 "/fhf profile own | shared — своё профиль для этого персонажа или общий".replace("своё профиль", "свой профиль"),
 "/fhf profile own | shared - perfil propio para este personaje o el compartido",
 "/fhf profile own | shared - profil propre à ce personnage ou profil partagé",
 "/fhf profile own | shared - perfil próprio para este personagem ou o compartilhado",
 "/fhf profile own | shared - 이 캐릭터 전용 프로필 또는 공용 프로필",
 "/fhf profile own | shared - 此角色专用配置或共享配置",
 "/fhf profile own | shared - 此角色專用設定檔或共用設定檔")
add("helpStatus",
 "/fhf status - what the addon found (for bug reports)",
 "/fhf status - was das Addon gefunden hat (für Fehlerberichte)",
 "/fhf status — что нашёл аддон (для сообщений об ошибках)",
 "/fhf status - lo que encontró el addon (para informar errores)",
 "/fhf status - ce que l'addon a trouvé (pour signaler un bug)",
 "/fhf status - o que o addon encontrou (para relatar erros)",
 "/fhf status - 애드온이 찾은 것 (버그 신고용)",
 "/fhf status - 插件找到的内容（用于报告错误）",
 "/fhf status - 插件找到的內容（用於回報錯誤）")
add("bugReport",
 "Found a bug or missing something? Tell us: %s",
 "Fehler gefunden oder fehlt dir etwas? Sag es uns: %s",
 "Нашёл ошибку или чего-то не хватает? Напиши нам: %s",
 "¿Encontraste un error o te falta algo? Cuéntanos: %s",
 "Un bug ou il te manque quelque chose ? Dis-le-nous : %s",
 "Achou um erro ou sente falta de algo? Conte para nós: %s",
 "버그를 찾았거나 필요한 기능이 있나요? 알려 주세요: %s",
 "发现错误或缺少功能？告诉我们：%s",
 "發現錯誤或缺少功能？告訴我們：%s")
add("unknown",
 "Unknown command. Type /fhf for help.",
 "Unbekannter Befehl. Gib /fhf für die Hilfe ein.",
 "Неизвестная команда. Набери /fhf для справки.",
 "Comando desconocido. Escribe /fhf para ver la ayuda.",
 "Commande inconnue. Tape /fhf pour l'aide.",
 "Comando desconhecido. Digite /fhf para ajuda.",
 "알 수 없는 명령어입니다. 도움말은 /fhf 를 입력하세요.",
 "未知命令。输入 /fhf 查看帮助。",
 "未知指令。輸入 /fhf 查看說明。")
add("locked", "Frame locked.", "Rahmen gesperrt.", "Рамка закреплена.", "Marco fijado.", "Cadre verrouillé.", "Quadro travado.", "프레임이 잠겼습니다.", "框体已锁定。", "框架已鎖定。")
add("unlocked",
 "Frame unlocked: drag it where you want it, then /fhf lock.",
 "Rahmen entsperrt: zieh ihn an die gewünschte Stelle, dann /fhf lock.",
 "Рамка откреплена: перетащи её куда нужно, потом /fhf lock.",
 "Marco desbloqueado: arrástralo adonde quieras y luego /fhf lock.",
 "Cadre déverrouillé : fais-le glisser où tu veux, puis /fhf lock.",
 "Quadro destravado: arraste para onde quiser e depois /fhf lock.",
 "프레임 잠금 해제: 원하는 곳으로 끌어다 놓은 뒤 /fhf lock.",
 "框体已解锁：拖到想要的位置，然后 /fhf lock。",
 "框架已解鎖：拖到想要的位置，然後 /fhf lock。")
add("autoLocked", "Fight started: frame locked.", "Kampf beginnt: Rahmen gesperrt.", "Бой начался: рамка закреплена.", "Empieza el combate: marco fijado.", "Le combat commence : cadre verrouillé.", "O combate começou: quadro travado.", "전투 시작: 프레임이 잠겼습니다.", "战斗开始：框体已锁定。", "戰鬥開始：框架已鎖定。")
add("holdOn",
 "Hints on hold until the end of the next fight.",
 "Hinweise pausiert bis zum Ende des nächsten Kampfes.",
 "Подсказки на паузе до конца следующего боя.",
 "Avisos en pausa hasta el final del próximo combate.",
 "Signaux en pause jusqu'à la fin du prochain combat.",
 "Avisos em pausa até o fim do próximo combate.",
 "다음 전투가 끝날 때까지 알림을 멈춥니다.",
 "提示暂停，直到下一场战斗结束。",
 "提示暫停，直到下一場戰鬥結束。")
add("holdOff", "Hints are back.", "Hinweise sind wieder da.", "Подсказки снова работают.", "Los avisos vuelven.", "Les signaux sont de retour.", "Os avisos voltaram.", "알림이 다시 켜졌습니다.", "提示已恢复。", "提示已恢復。")
add("posReset", "Frame back to its default place.", "Rahmen zurück am Standardplatz.", "Рамка на месте по умолчанию.", "Marco en su sitio por defecto.", "Cadre remis à sa place par défaut.", "Quadro de volta ao lugar padrão.", "프레임이 기본 위치로 돌아갔습니다.", "框体已回到默认位置。", "框架已回到預設位置。")
add("profShared", "This character uses the shared profile.", "Dieser Charakter nutzt das gemeinsame Profil.", "Этот персонаж использует общий профиль.", "Este personaje usa el perfil compartido.", "Ce personnage utilise le profil partagé.", "Este personagem usa o perfil compartilhado.", "이 캐릭터는 공용 프로필을 사용합니다.", "此角色使用共享配置。", "此角色使用共用設定檔。")
add("profOwn", "This character uses its own profile.", "Dieser Charakter nutzt ein eigenes Profil.", "Этот персонаж использует свой профиль.", "Este personaje usa su propio perfil.", "Ce personnage utilise son propre profil.", "Este personagem usa o próprio perfil.", "이 캐릭터는 전용 프로필을 사용합니다.", "此角色使用专用配置。", "此角色使用專用設定檔。")
add("profNone",
 "The game has not told the character's name yet: try again in a moment.",
 "Das Spiel kennt den Namen des Charakters noch nicht: versuch es gleich noch einmal.",
 "Игра ещё не сообщила имя персонажа: попробуй через пару секунд.",
 "El juego aún no ha dado el nombre del personaje: inténtalo de nuevo en un momento.",
 "Le jeu n'a pas encore donné le nom du personnage : réessaie dans un instant.",
 "O jogo ainda não informou o nome do personagem: tente de novo em instantes.",
 "게임이 아직 캐릭터 이름을 알려 주지 않았습니다. 잠시 후 다시 시도하세요.",
 "游戏尚未提供角色名称：请稍后再试。",
 "遊戲尚未提供角色名稱：請稍後再試。")
add("profReset", "Profile back to the defaults.", "Profil auf die Standardwerte zurückgesetzt.", "Профиль сброшен к значениям по умолчанию.", "Perfil restablecido a los valores por defecto.", "Profil remis aux valeurs par défaut.", "Perfil voltou ao padrão.", "프로필이 기본값으로 돌아갔습니다.", "配置已恢复默认。", "設定檔已恢復預設。")
add("langReload", "The language changes after /reload.", "Die Sprache wechselt nach /reload.", "Язык сменится после /reload.", "El idioma cambia después de /reload.", "La langue change après /reload.", "O idioma muda depois de /reload.", "언어는 /reload 후에 바뀝니다.", "语言将在 /reload 后切换。", "語言將在 /reload 後切換。")
add("holdLabel", "HOLD", "PAUSE", "ПАУЗА", "PAUSA", "PAUSE", "PAUSA", "보류", "暂停", "暫停")
add("aggroLabel", "AGGRO", "AGGRO", "АГРО", "AGGRO", "AGGRO", "AGGRO", "어그로", "仇恨", "仇恨")
add("lostLabel", "LOOSE", "FREI", "СОРВАЛСЯ", "SUELTO", "LIBRE", "SOLTO", "놓침", "脱离", "脫離")
add("dragHint", "Full Health Forever: drag me", "Full Health Forever: zieh mich", "Full Health Forever: перетащи меня", "Full Health Forever: arrástrame", "Full Health Forever : fais-moi glisser", "Full Health Forever: arraste-me", "Full Health Forever: 끌어서 옮기기", "Full Health Forever：拖动我", "Full Health Forever：拖動我")
add("dragTip",
 "Drag to move the frame. Right-click: settings. Lock it in the settings or with /fhf lock.",
 "Ziehen verschiebt den Rahmen. Rechtsklick: Einstellungen. Sperren in den Einstellungen oder mit /fhf lock.",
 "Перетащи, чтобы передвинуть рамку. Правый клик — настройки. Закрепить можно в настройках или командой /fhf lock.",
 "Arrastra para mover el marco. Clic derecho: ajustes. Fíjalo en los ajustes o con /fhf lock.",
 "Fais glisser pour déplacer le cadre. Clic droit : réglages. Verrouille-le dans les réglages ou avec /fhf lock.",
 "Arraste para mover o quadro. Clique direito: configurações. Trave nas configurações ou com /fhf lock.",
 "끌어서 프레임을 옮깁니다. 오른쪽 클릭: 설정. 설정이나 /fhf lock 으로 잠급니다.",
 "拖动以移动框体。右键：设置。可在设置中或用 /fhf lock 锁定。",
 "拖動以移動框架。右鍵：設定。可在設定中或用 /fhf lock 鎖定。")
add("tipDragWindow",
 "Drag the title to move the window. Esc closes it.",
 "Am Titel ziehen verschiebt das Fenster. Esc schließt es.",
 "Перетащи за заголовок, чтобы передвинуть окно. Esc закрывает его.",
 "Arrastra el título para mover la ventana. Esc la cierra.",
 "Fais glisser le titre pour déplacer la fenêtre. Échap la ferme.",
 "Arraste o título para mover a janela. Esc fecha.",
 "제목을 끌어서 창을 옮깁니다. Esc 키로 닫습니다.",
 "拖动标题以移动窗口。Esc 关闭。",
 "拖動標題以移動視窗。Esc 關閉。")
add("secGeneral", "General", "Allgemein", "Общее", "General", "Général", "Geral", "일반", "常规", "一般")
add("secDanger", "When to light up", "Wann aufleuchten", "Когда загораться", "Cuándo iluminarse", "Quand s'allumer", "Quando acender", "켜지는 때", "何时亮起", "何時亮起")
add("secIcons", "Icons", "Symbole", "Иконки", "Iconos", "Icônes", "Ícones", "아이콘", "图标", "圖示")
add("secBar", "Health bar", "Gesundheitsleiste", "Полоса здоровья", "Barra de salud", "Barre de santé", "Barra de vida", "생명력 바", "生命条", "生命條")
add("secProfile", "Profile", "Profil", "Профиль", "Perfil", "Profil", "Perfil", "프로필", "配置", "設定檔")
add("optLocked", "Lock frame", "Rahmen sperren", "Закрепить рамку", "Fijar marco", "Verrouiller le cadre", "Travar quadro", "프레임 잠금", "锁定框体", "鎖定框架")
add("tipLocked",
 "Unlocked, the frame shows all the time and can be dragged. It locks itself when a fight starts.",
 "Entsperrt ist der Rahmen immer sichtbar und lässt sich ziehen. Beim Kampfbeginn sperrt er sich selbst.",
 "Откреплённая рамка видна всегда и перетаскивается. Когда начинается бой, она закрепляется сама.",
 "Desbloqueado, el marco se ve siempre y se puede arrastrar. Se fija solo al empezar un combate.",
 "Déverrouillé, le cadre est toujours visible et peut être déplacé. Il se verrouille tout seul au début d'un combat.",
 "Destravado, o quadro aparece o tempo todo e pode ser arrastado. Ele trava sozinho quando um combate começa.",
 "잠금 해제하면 프레임이 항상 보이고 끌어서 옮길 수 있습니다. 전투가 시작되면 저절로 잠깁니다.",
 "解锁后框体始终显示并可拖动。战斗开始时会自动锁定。",
 "解鎖後框架始終顯示並可拖動。戰鬥開始時會自動鎖定。")
add("optOnlyCombat", "Show only in combat", "Nur im Kampf zeigen", "Показывать только в бою", "Mostrar solo en combate", "Afficher seulement en combat", "Mostrar só em combate", "전투 중에만 표시", "仅在战斗中显示", "僅在戰鬥中顯示")
add("tipOnlyCombat",
 "Out of combat the bar and the icons are hidden. While the settings are open or the frame is unlocked, it always shows.",
 "Außerhalb des Kampfes sind Leiste und Symbole versteckt. Bei offenen Einstellungen oder entsperrtem Rahmen ist er immer sichtbar.",
 "Вне боя полоса и иконки скрыты. Пока открыты настройки или рамка откреплена, она видна всегда.",
 "Fuera de combate la barra y los iconos se ocultan. Con los ajustes abiertos o el marco desbloqueado se ve siempre.",
 "Hors combat, la barre et les icônes sont cachées. Réglages ouverts ou cadre déverrouillé : toujours visible.",
 "Fora de combate a barra e os ícones ficam ocultos. Com as configurações abertas ou o quadro destravado, aparece sempre.",
 "전투 밖에서는 바와 아이콘이 숨겨집니다. 설정이 열려 있거나 프레임 잠금이 풀려 있으면 항상 보입니다.",
 "战斗外隐藏生命条和图标。设置打开或框体解锁时始终显示。",
 "戰鬥外隱藏生命條和圖示。設定開啟或框架解鎖時始終顯示。")
add("showSolo", "Solo", "Solo", "Соло", "Solo", "Solo", "Solo", "솔로", "单人", "單人")
add("showParty", "In a party", "In der Gruppe", "В группе", "En grupo", "En groupe", "Em grupo", "파티", "小队中", "隊伍中")
add("showRaid", "In a raid", "Im Schlachtzug", "В рейде", "En banda", "En raid", "Em raide", "공격대", "团队中", "團隊中")
add("tipShowIn",
 "Where the frame shows. Switched off: hidden there.",
 "Wo der Rahmen erscheint. Ausgeschaltet: dort versteckt.",
 "Где показывать рамку. Выключено — там она скрыта.",
 "Dónde se muestra el marco. Desactivado: oculto allí.",
 "Où le cadre s'affiche. Désactivé : caché à cet endroit.",
 "Onde o quadro aparece. Desligado: oculto ali.",
 "프레임을 표시할 곳입니다. 끄면 그곳에서는 숨겨집니다.",
 "在何处显示框体。关闭：在该处隐藏。",
 "在何處顯示框架。關閉：在該處隱藏。")
add("optScale", "Size", "Größe", "Размер", "Tamaño", "Taille", "Tamanho", "크기", "大小", "大小")
add("tipScale", "Size of the whole frame: bar and icons.", "Größe des ganzen Rahmens: Leiste und Symbole.", "Размер всей рамки: полоса и иконки.", "Tamaño de todo el marco: barra e iconos.", "Taille de tout le cadre : barre et icônes.", "Tamanho do quadro inteiro: barra e ícones.", "프레임 전체 크기: 바와 아이콘.", "整个框体的大小：生命条和图标。", "整個框架的大小：生命條和圖示。")
add("optLanguage", "Language", "Sprache", "Язык", "Idioma", "Langue", "Idioma", "언어", "语言", "語言")
add("tipLanguage", "Language of the addon's texts. Changes after /reload.", "Sprache der Texte des Addons. Wechselt nach /reload.", "Язык текстов аддона. Сменится после /reload.", "Idioma de los textos del addon. Cambia después de /reload.", "Langue des textes de l'addon. Change après /reload.", "Idioma dos textos do addon. Muda depois de /reload.", "애드온 텍스트의 언어. /reload 후에 바뀝니다.", "插件文字的语言。/reload 后生效。", "插件文字的語言。/reload 後生效。")
add("langAuto", "Game language", "Spielsprache", "Язык игры", "Idioma del juego", "Langue du jeu", "Idioma do jogo", "게임 언어", "游戏语言", "遊戲語言")
add("optRole", "Role", "Rolle", "Роль", "Rol", "Rôle", "Função", "역할", "职责", "職責")
add("tipRole",
 "Automatic: the role the group gives you; solo counts as damage. Tank: own defensives first, one line, the aggro icon shows a target that is not on you. Healer: healthstone first, potion last (it shares the cooldown with your mana potion).",
 "Automatisch: die Rolle, die dir die Gruppe gibt; solo zählt als Schaden. Tank: eigene Verteidigung zuerst, eine Linie, das Aggro-Symbol zeigt ein Ziel, das nicht dich angreift. Heiler: Gesundheitsstein zuerst, Trank zuletzt (er teilt die Abklingzeit mit deinem Manatrank).",
 "Автоматически — роль, которую тебе даёт группа; соло считается уроном. Танк: сначала свои защитные, одна линия, значок агро показывает цель, которая бьёт не тебя. Хилер: сначала камень здоровья, зелье последним (у него общий кулдаун с зельем маны).",
 "Automático: el rol que te da el grupo; en solitario cuenta como daño. Tanque: primero tus defensas, una sola línea, el icono de amenaza muestra un objetivo que no te ataca a ti. Sanador: primero la piedra de salud, la poción al final (comparte el tiempo de reutilización con tu poción de maná).",
 "Automatique : le rôle que te donne le groupe ; en solo, compte comme dégâts. Tank : tes défenses d'abord, une seule ligne, l'icône de menace montre une cible qui ne te frappe pas. Soigneur : pierre de soins d'abord, potion en dernier (elle partage le temps de recharge avec ta potion de mana).",
 "Automático: a função que o grupo te dá; solo conta como dano. Tanque: suas defesas primeiro, uma só linha, o ícone de aggro mostra um alvo que não está em você. Curador: pedra de vida primeiro, poção por último (ela divide a recarga com a poção de mana).",
 "자동: 파티가 정해 준 역할, 솔로는 공격 담당으로 칩니다. 방어 담당: 자신의 방어 기술 먼저, 기준선 하나, 어그로 아이콘은 나를 치지 않는 대상을 보여 줍니다. 치유 담당: 생명석 먼저, 물약은 마지막 (마나 물약과 재사용 대기시간을 공유함).",
 "自动：队伍给你的职责；单人算作伤害。坦克：先用自己的防御技能，只有一条线，仇恨图标表示目标没在打你。治疗：先用治疗石，药水最后（与法力药水共享冷却）。",
 "自動：隊伍給你的職責；單人算作傷害。坦克：先用自己的防禦技能，只有一條線，仇恨圖示表示目標沒在打你。治療：先用治療石，藥水最後（與法力藥水共用冷卻）。")
add("roleAuto", "Automatic", "Automatisch", "Автоматически", "Automático", "Automatique", "Automático", "자동", "自动", "自動")
add("roleTank", "Tank", "Tank", "Танк", "Tanque", "Tank", "Tanque", "방어 담당", "坦克", "坦克")
add("roleHealer", "Healer", "Heiler", "Хилер", "Sanador", "Soigneur", "Curador", "치유 담당", "治疗", "治療")
add("roleDps", "Damage / solo", "Schaden / solo", "Урон / соло", "Daño / solo", "Dégâts / solo", "Dano / solo", "공격 담당 / 솔로", "伤害 / 单人", "傷害 / 單人")
add("optThrAggro", "Line, mob on you", "Linie, Gegner auf dir", "Линия, моб на тебе", "Línea, enemigo encima", "Ligne, ennemi sur toi", "Linha, inimigo em você", "기준선, 적이 나를 공격", "线：怪在打你", "線：怪在打你")
add("tipThrAggro",
 "Icons light up when your health is below this line AND the heals being cast on you will not lift it above. Used while a mob is on you (also solo in a fight).",
 "Symbole leuchten, wenn deine Gesundheit unter dieser Linie ist UND die Heilungen, die gerade auf dich gewirkt werden, sie nicht darüber heben. Gilt, solange ein Gegner dich angreift (auch solo im Kampf).",
 "Иконки загораются, когда здоровье ниже этой линии И хил, который сейчас кастуют на тебя, не поднимет его выше. Действует, пока моб бьёт тебя (и соло в бою).",
 "Los iconos se iluminan cuando tu salud está por debajo de esta línea Y las curaciones que te están lanzando no la subirán por encima. Se usa mientras un enemigo te ataca (también en solitario en combate).",
 "Les icônes s'allument quand ta santé est sous cette ligne ET que les soins en cours d'incantation sur toi ne la feront pas remonter au-dessus. Utilisée tant qu'un ennemi te frappe (aussi en solo en combat).",
 "Os ícones acendem quando sua vida está abaixo desta linha E as curas sendo lançadas em você não vão subi-la acima. Vale enquanto um inimigo está em você (também solo em combate).",
 "생명력이 이 기준선 아래이고, 지금 나에게 시전 중인 치유로도 그 위로 올라가지 않을 때 아이콘이 켜집니다. 적이 나를 공격하는 동안 적용 (솔로 전투 포함).",
 "当你的生命低于这条线，并且正在对你施放的治疗不会把它抬到线以上时，图标亮起。在怪打你时使用（单人战斗也是）。",
 "當你的生命低於這條線，並且正在對你施放的治療不會把它抬到線以上時，圖示亮起。在怪打你時使用（單人戰鬥也是）。")
add("optThrNoAggro", "Line, no mob on you", "Linie, kein Gegner auf dir", "Линия, моб не на тебе", "Línea, sin enemigo encima", "Ligne, aucun ennemi sur toi", "Linha, sem inimigo em você", "기준선, 나를 공격하는 적 없음", "线：没有怪打你", "線：沒有怪打你")
add("tipThrNoAggro",
 "The same line while no mob is on you: lower, because nobody hits you right now.",
 "Dieselbe Linie, solange dich kein Gegner angreift: niedriger, weil dich gerade niemand trifft.",
 "Та же линия, пока моб не на тебе: ниже, потому что тебя сейчас никто не бьёт.",
 "La misma línea mientras ningún enemigo te ataca: más baja, porque ahora nadie te golpea.",
 "La même ligne tant qu'aucun ennemi ne te frappe : plus basse, car personne ne te tape en ce moment.",
 "A mesma linha enquanto nenhum inimigo está em você: mais baixa, porque ninguém está te batendo agora.",
 "나를 공격하는 적이 없을 때의 기준선: 지금은 아무도 나를 때리지 않으니 더 낮습니다.",
 "没有怪打你时的线：更低，因为此刻没人在打你。",
 "沒有怪打你時的線：更低，因為此刻沒人在打你。")
add("optThrTank", "Line, tank", "Linie, Tank", "Линия, танк", "Línea, tanque", "Ligne, tank", "Linha, tanque", "기준선, 방어 담당", "线：坦克", "線：坦克")
add("tipThrTank",
 "The line for tanks: healers keep a tank low on purpose, so it is lower and the same with or without aggro.",
 "Die Linie für Tanks: Heiler halten einen Tank absichtlich niedrig, daher ist sie tiefer und mit oder ohne Aggro gleich.",
 "Линия для танков: хилеры нарочно держат танка низко, поэтому она ниже и одна и та же с агро и без.",
 "La línea para tanques: los sanadores mantienen bajo al tanque a propósito, así que es más baja e igual con o sin amenaza.",
 "La ligne des tanks : les soigneurs gardent un tank bas exprès, elle est donc plus basse et la même avec ou sans menace.",
 "A linha para tanques: curadores deixam o tanque baixo de propósito, então ela é mais baixa e igual com ou sem aggro.",
 "방어 담당용 기준선: 치유 담당은 일부러 방어 담당의 생명력을 낮게 유지하므로 더 낮고, 어그로와 상관없이 같습니다.",
 "坦克用的线：治疗会故意让坦克血量偏低，所以这条线更低，有没有仇恨都一样。",
 "坦克用的線：治療會故意讓坦克血量偏低，所以這條線更低，有沒有仇恨都一樣。")
add("optCalm", "Show ready icons dimmed", "Bereite Symbole gedimmt zeigen", "Показывать готовые иконки приглушённо", "Mostrar iconos listos atenuados", "Afficher les icônes prêtes atténuées", "Mostrar ícones prontos esmaecidos", "준비된 아이콘을 흐리게 표시", "淡显已就绪的图标", "淡顯已就緒的圖示")
add("tipCalm",
 "Without danger, ready icons show dimmed, so you see what you have. Off: only the grey row and the lit icons.",
 "Ohne Gefahr erscheinen bereite Symbole gedimmt, damit du siehst, was du hast. Aus: nur die graue Reihe und leuchtende Symbole.",
 "Без опасности готовые иконки видны приглушённо — видно, что у тебя есть. Выключено: только серый ряд и горящие иконки.",
 "Sin peligro, los iconos listos se ven atenuados para que sepas lo que tienes. Desactivado: solo la fila gris y los iconos iluminados.",
 "Sans danger, les icônes prêtes s'affichent atténuées pour que tu voies ce que tu as. Désactivé : seulement la rangée grise et les icônes allumées.",
 "Sem perigo, os ícones prontos aparecem esmaecidos, para você ver o que tem. Desligado: só a fileira cinza e os ícones acesos.",
 "위험이 없을 때 준비된 아이콘을 흐리게 보여 주어 가진 것을 알 수 있습니다. 끄면 회색 줄과 켜진 아이콘만 보입니다.",
 "没有危险时，已就绪的图标淡淡显示，方便看到你有什么。关闭：只显示灰色一排和亮起的图标。",
 "沒有危險時，已就緒的圖示淡淡顯示，方便看到你有什麼。關閉：只顯示灰色一排和亮起的圖示。")
add("grp_stone", "Healthstone", "Gesundheitsstein", "Камень здоровья", "Piedra de salud", "Pierre de soins", "Pedra de vida", "생명석", "治疗石", "治療石")
add("grp_potion", "Healing potion", "Heiltrank", "Лечебное зелье", "Poción de sanación", "Potion de soins", "Poção de cura", "치유 물약", "治疗药水", "治療藥水")
add("grp_bandage", "Bandage", "Verband", "Бинт", "Venda", "Bandage", "Atadura", "붕대", "绷带", "繃帶")
add("grp_defensive", "Own defensive spells", "Eigene Verteidigungszauber", "Свои защитные умения", "Hechizos defensivos propios", "Tes sorts défensifs", "Feitiços defensivos próprios", "자신의 방어 주문", "自身防御技能", "自身防禦技能")
add("tipGrp_stone", "The strongest healthstone in your bags.", "Der stärkste Gesundheitsstein in deinen Taschen.", "Самый сильный камень здоровья в сумках.", "La piedra de salud más fuerte de tus bolsas.", "La pierre de soins la plus forte de tes sacs.", "A pedra de vida mais forte das suas bolsas.", "가방에 있는 가장 강한 생명석.", "背包里最强的治疗石。", "背包裡最強的治療石。")
add("tipGrp_potion", "The strongest healing potion in your bags.", "Der stärkste Heiltrank in deinen Taschen.", "Самое сильное лечебное зелье в сумках.", "La poción de sanación más fuerte de tus bolsas.", "La potion de soins la plus forte de tes sacs.", "A poção de cura mais forte das suas bolsas.", "가방에 있는 가장 강한 치유 물약.", "背包里最强的治疗药水。", "背包裡最強的治療藥水。")
add("tipGrp_bandage",
 "The strongest bandage you can use. Lights up only while no mob is on you (damage stops a bandage) and not within 60 s of the last one.",
 "Der stärkste Verband, den du benutzen kannst. Leuchtet nur, solange dich kein Gegner angreift (Schaden bricht den Verband ab), und nicht innerhalb von 60 s nach dem letzten.",
 "Самый сильный бинт, который ты можешь наложить. Загорается, только пока моб не на тебе (урон сбивает бинт), и не раньше чем через 60 с после прошлого.",
 "La venda más fuerte que puedes usar. Se ilumina solo mientras ningún enemigo te ataca (el daño interrumpe la venda) y no antes de 60 s desde la última.",
 "Le bandage le plus fort que tu peux utiliser. S'allume seulement tant qu'aucun ennemi ne te frappe (les dégâts l'interrompent) et pas moins de 60 s après le dernier.",
 "A atadura mais forte que você pode usar. Acende só enquanto nenhum inimigo está em você (dano interrompe a atadura) e não antes de 60 s da última.",
 "사용할 수 있는 가장 강한 붕대. 나를 공격하는 적이 없을 때만 켜지고 (피해를 받으면 붕대가 끊김), 마지막 붕대 후 60초 안에는 켜지지 않습니다.",
 "你能使用的最强绷带。只在没有怪打你时亮起（受到伤害会打断绷带），且上次使用后 60 秒内不亮。",
 "你能使用的最強繃帶。只在沒有怪打你時亮起（受到傷害會打斷繃帶），且上次使用後 60 秒內不亮。")
add("tipGrp_defensive",
 "Your class's defensive spells (e.g. Shield Wall, Evasion, Ice Block, Lay on Hands). Paladin tanks: no Divine Shield or Divine Protection (they drop the aggro).",
 "Die Verteidigungszauber deiner Klasse (z. B. Schildwall, Entrinnen, Eisblock, Handauflegung). Paladin-Tanks: kein Gottesschild und kein Göttlicher Schutz (sie lassen die Aggro fallen).",
 "Защитные умения твоего класса (например, Глухая оборона, Ускользание, Ледяная глыба, Возложение рук). Паладину-танку — без Божественного щита и Божественной защиты (они сбрасывают агро).",
 "Los hechizos defensivos de tu clase (p. ej. Muro de escudo, Evasión, Bloque de hielo, Imposición de manos). Paladines tanque: sin Escudo divino ni Protección divina (pierden la amenaza).",
 "Les sorts défensifs de ta classe (par ex. Mur protecteur, Évasion, Bloc de glace, Imposition des mains). Paladins tanks : pas de Bouclier divin ni de Protection divine (ils font perdre la menace).",
 "Os feitiços defensivos da sua classe (ex.: Parede de Escudos, Evasão, Bloco de Gelo, Impor as Mãos). Paladinos tanque: sem Escudo Divino nem Proteção Divina (eles perdem o aggro).",
 "직업의 방어 주문 (예: 방패의 벽, 회피, 얼음 덩이, 신의 축복). 성기사 방어 담당: 천상의 보호막과 신의 가호는 제외 (어그로를 잃음).",
 "你职业的防御技能（如盾墙、闪避、寒冰屏障、圣疗术）。圣骑士坦克：不含圣盾术和圣佑术（会丢失仇恨）。",
 "你職業的防禦技能（如盾牆、閃避、寒冰屏障、聖療術）。聖騎士坦克：不含聖盾術和聖佑術（會失去仇恨）。")
add("optIconSize", "Icon size", "Symbolgröße", "Размер иконок", "Tamaño de los iconos", "Taille des icônes", "Tamanho dos ícones", "아이콘 크기", "图标大小", "圖示大小")
add("tipIconSize", "Width and height of the icons.", "Breite und Höhe der Symbole.", "Ширина и высота иконок.", "Ancho y alto de los iconos.", "Largeur et hauteur des icônes.", "Largura e altura dos ícones.", "아이콘의 너비와 높이.", "图标的宽度和高度。", "圖示的寬度和高度。")
add("optHealthText", "Health text", "Gesundheitstext", "Текст здоровья", "Texto de salud", "Texte de santé", "Texto de vida", "생명력 텍스트", "生命文字", "生命文字")
add("tipHealthText",
 "What the bar shows as text. The game fills in the numbers itself: addons cannot read your health in Forever.",
 "Was die Leiste als Text zeigt. Die Zahlen setzt das Spiel selbst ein: Addons können deine Gesundheit in Forever nicht lesen.",
 "Что полоса показывает текстом. Числа подставляет сама игра: в Forever аддоны не могут прочитать твоё здоровье.",
 "Lo que la barra muestra como texto. El juego pone los números: en Forever los addons no pueden leer tu salud.",
 "Ce que la barre affiche en texte. Le jeu remplit les chiffres lui-même : dans Forever, les addons ne peuvent pas lire ta santé.",
 "O que a barra mostra como texto. O próprio jogo preenche os números: no Forever os addons não conseguem ler sua vida.",
 "바에 텍스트로 표시할 내용. 숫자는 게임이 직접 채웁니다. Forever 에서는 애드온이 생명력을 읽을 수 없습니다.",
 "生命条上显示的文字。数字由游戏自己填写：在 Forever 中插件无法读取你的生命值。",
 "生命條上顯示的文字。數字由遊戲自己填寫：在 Forever 中插件無法讀取你的生命值。")
add("htPercent", "Percent", "Prozent", "Проценты", "Porcentaje", "Pourcentage", "Porcentagem", "백분율", "百分比", "百分比")
add("htValue", "Value", "Wert", "Значение", "Valor", "Valeur", "Valor", "수치", "数值", "數值")
add("htBoth", "Both", "Beides", "Оба", "Ambos", "Les deux", "Ambos", "둘 다", "两者", "兩者")
add("htOff", "Off", "Aus", "Нет", "Ninguno", "Aucun", "Nenhum", "끄기", "关闭", "關閉")
add("optShadow", "Shadow: health a moment ago", "Schatten: Gesundheit von eben", "Тень: здоровье мгновение назад", "Sombra: salud de hace un momento", "Ombre : santé d'il y a un instant", "Sombra: vida de um instante atrás", "그림자: 조금 전 생명력", "阴影：片刻前的生命", "陰影：片刻前的生命")
add("tipShadow",
 "A dark red bar under your health shows where it was a moment ago: the bigger the gap, the faster you are losing health. Forever hides damage numbers from addons; this is the honest view of them.",
 "Eine dunkelrote Leiste unter deiner Gesundheit zeigt, wo sie eben noch war: je größer die Lücke, desto schneller verlierst du Gesundheit. Forever verbirgt Schadenszahlen vor Addons; das ist der ehrliche Blick darauf.",
 "Тёмно-красная полоса под здоровьем показывает, где оно было мгновение назад: чем больше разрыв, тем быстрее ты теряешь здоровье. Forever скрывает от аддонов числа урона — это честный способ их увидеть.",
 "Una barra rojo oscuro bajo tu salud muestra dónde estaba hace un momento: cuanto mayor el hueco, más rápido pierdes salud. Forever oculta a los addons las cifras de daño; esta es la vista honesta.",
 "Une barre rouge foncé sous ta santé montre où elle était il y a un instant : plus l'écart est grand, plus tu perds de la santé vite. Forever cache les chiffres de dégâts aux addons ; c'est la vue honnête.",
 "Uma barra vermelho-escura sob sua vida mostra onde ela estava um instante atrás: quanto maior a diferença, mais rápido você perde vida. O Forever esconde os números de dano dos addons; esta é a visão honesta.",
 "생명력 아래의 짙은 빨간 바가 조금 전 생명력을 보여 줍니다. 차이가 클수록 빨리 잃고 있는 것입니다. Forever 는 애드온에 피해 수치를 숨기므로 이것이 정직한 표시입니다.",
 "生命条下的深红条显示片刻前的生命：差距越大，掉血越快。Forever 不让插件看到伤害数字，这是诚实的显示方式。",
 "生命條下的深紅條顯示片刻前的生命：差距越大，掉血越快。Forever 不讓插件看到傷害數字，這是誠實的顯示方式。")
add("optShadowSec", "Shadow delay", "Schattenverzögerung", "Задержка тени", "Retraso de la sombra", "Retard de l'ombre", "Atraso da sombra", "그림자 지연", "阴影延迟", "陰影延遲")
add("tipShadowSec", "How far back the shadow looks.", "Wie weit der Schatten zurückblickt.", "Насколько назад смотрит тень.", "Cuánto tiempo atrás mira la sombra.", "Jusqu'où l'ombre regarde en arrière.", "Até quanto tempo atrás a sombra olha.", "그림자가 얼마나 이전을 보여 주는지.", "阴影回看多久之前。", "陰影回看多久之前。")
add("secondsFmt", "%.1f s", "%.1f s", "%.1f с", "%.1f s", "%.1f s", "%.1f s", "%.1f초", "%.1f 秒", "%.1f 秒")
add("optBarWidth", "Bar width", "Leistenbreite", "Ширина полосы", "Ancho de la barra", "Largeur de la barre", "Largura da barra", "바 너비", "生命条宽度", "生命條寬度")
add("tipBarWidth", "Width of the health bar.", "Breite der Gesundheitsleiste.", "Ширина полосы здоровья.", "Ancho de la barra de salud.", "Largeur de la barre de santé.", "Largura da barra de vida.", "생명력 바의 너비.", "生命条的宽度。", "生命條的寬度。")
add("optBarHeight", "Bar height", "Leistenhöhe", "Высота полосы", "Alto de la barra", "Hauteur de la barre", "Altura da barra", "바 높이", "生命条高度", "生命條高度")
add("tipBarHeight", "Height of the health bar.", "Höhe der Gesundheitsleiste.", "Высота полосы здоровья.", "Alto de la barra de salud.", "Hauteur de la barre de santé.", "Altura da barra de vida.", "생명력 바의 높이.", "生命条的高度。", "生命條的高度。")
add("optThreat", "Aggro warning", "Aggro-Warnung", "Предупреждение об агро", "Aviso de amenaza", "Alerte de menace", "Aviso de aggro", "어그로 경고", "仇恨警告", "仇恨警告")
add("tipThreat",
 "In a group: an icon left of the bar when a mob is on you (not for tanks). Tanks: when your target is not on you.",
 "In der Gruppe: ein Symbol links der Leiste, wenn ein Gegner dich angreift (nicht für Tanks). Tanks: wenn dein Ziel nicht dich angreift.",
 "В группе: значок слева от полосы, когда моб бьёт тебя (не для танков). Танкам — когда твоя цель бьёт не тебя.",
 "En grupo: un icono a la izquierda de la barra cuando un enemigo te ataca (no para tanques). Tanques: cuando tu objetivo no te ataca a ti.",
 "En groupe : une icône à gauche de la barre quand un ennemi te frappe (pas pour les tanks). Tanks : quand ta cible ne te frappe pas.",
 "Em grupo: um ícone à esquerda da barra quando um inimigo está em você (não para tanques). Tanques: quando seu alvo não está em você.",
 "파티에서: 적이 나를 공격하면 바 왼쪽에 아이콘 (방어 담당 제외). 방어 담당: 내 대상이 나를 공격하지 않을 때.",
 "队伍中：有怪打你时在生命条左侧显示图标（坦克除外）。坦克：你的目标没在打你时。",
 "隊伍中：有怪打你時在生命條左側顯示圖示（坦克除外）。坦克：你的目標沒在打你時。")
add("optProfile", "Profile", "Profil", "Профиль", "Perfil", "Profil", "Perfil", "프로필", "配置", "設定檔")
add("tipProfile",
 "Shared: the settings all characters use. Own: a copy of Shared only for this character; kept when you switch back.",
 "Gemeinsam: die Einstellungen aller Charaktere. Eigenes: eine Kopie von Gemeinsam nur für diesen Charakter; bleibt erhalten, wenn du zurückwechselst.",
 "Общий — настройки для всех персонажей. Свой — копия общего только для этого персонажа; сохраняется, если вернёшься на общий.",
 "Compartido: los ajustes que usan todos los personajes. Propio: una copia del compartido solo para este personaje; se conserva si vuelves al compartido.",
 "Partagé : les réglages de tous les personnages. Propre : une copie du partagé pour ce personnage seul ; conservée si tu reviens au partagé.",
 "Compartilhado: as configurações de todos os personagens. Próprio: uma cópia do compartilhado só para este personagem; é mantida se você voltar.",
 "공용: 모든 캐릭터가 쓰는 설정. 전용: 이 캐릭터만 쓰는 공용 설정의 복사본, 공용으로 돌아가도 남아 있습니다.",
 "共享：所有角色使用的设置。专用：仅此角色使用的共享设置副本；切回共享后仍保留。",
 "共用：所有角色使用的設定。專用：僅此角色使用的共用設定副本；切回共用後仍保留。")
add("profSharedName", "Shared", "Gemeinsam", "Общий", "Compartido", "Partagé", "Compartilhado", "공용", "共享", "共用")
add("profOwnName", "Own (this character)", "Eigenes (dieser Charakter)", "Свой (этот персонаж)", "Propio (este personaje)", "Propre (ce personnage)", "Próprio (este personagem)", "전용 (이 캐릭터)", "专用（此角色）", "專用（此角色）")
add("btnResetProfile", "Reset profile", "Profil zurücksetzen", "Сбросить профиль", "Restablecer perfil", "Réinitialiser le profil", "Redefinir perfil", "프로필 초기화", "重置配置", "重置設定檔")
add("tipResetProfile",
 "The profile in use back to the defaults. Click twice to confirm.",
 "Das benutzte Profil auf die Standardwerte zurücksetzen. Zum Bestätigen zweimal klicken.",
 "Вернуть текущий профиль к значениям по умолчанию. Нажми дважды для подтверждения.",
 "Devuelve el perfil en uso a los valores por defecto. Haz clic dos veces para confirmar.",
 "Remet le profil utilisé aux valeurs par défaut. Clique deux fois pour confirmer.",
 "Volta o perfil em uso ao padrão. Clique duas vezes para confirmar.",
 "사용 중인 프로필을 기본값으로 되돌립니다. 확인하려면 두 번 클릭하세요.",
 "将当前配置恢复默认。点击两次确认。",
 "將目前設定檔恢復預設。點擊兩次確認。")
add("resetConfirm", "Click again", "Noch einmal klicken", "Нажми ещё раз", "Clic otra vez", "Clique encore", "Clique de novo", "한 번 더 클릭", "再点一次", "再點一次")
add("btnResetPos", "Reset position", "Position zurücksetzen", "Сбросить позицию", "Restablecer posición", "Réinitialiser la position", "Redefinir posição", "위치 초기화", "重置位置", "重置位置")
add("tipResetPos", "The frame back to its default place.", "Den Rahmen zurück an den Standardplatz.", "Вернуть рамку на место по умолчанию.", "Devuelve el marco a su sitio por defecto.", "Remet le cadre à sa place par défaut.", "Devolve o quadro ao lugar padrão.", "프레임을 기본 위치로 되돌립니다.", "框体回到默认位置。", "框架回到預設位置。")
add("btnClose", "Close", "Schließen", "Закрыть", "Cerrar", "Fermer", "Fechar", "닫기", "关闭", "關閉")
add("tipClose", "Close the settings (Esc also works).", "Einstellungen schließen (Esc geht auch).", "Закрыть настройки (можно и Esc).", "Cerrar los ajustes (Esc también sirve).", "Fermer les réglages (Échap marche aussi).", "Fechar as configurações (Esc também funciona).", "설정 닫기 (Esc 키도 됩니다).", "关闭设置（Esc 也可以）。", "關閉設定（Esc 也可以）。")
add("btnHold", "Hold", "Pause", "Пауза", "Pausa", "Pause", "Pausa", "보류", "暂停", "暫停")
add("tipHold",
 "No lit icons until the end of the next fight, for when you want to save a cooldown. Also /fhf hold (handy in a macro).",
 "Keine leuchtenden Symbole bis zum Ende des nächsten Kampfes, wenn du eine Abklingzeit sparen willst. Auch /fhf hold (praktisch als Makro).",
 "Никаких горящих иконок до конца следующего боя — когда хочешь приберечь кулдаун. Также /fhf hold (удобно в макросе).",
 "Ningún icono iluminado hasta el final del próximo combate, para guardar un tiempo de reutilización. También /fhf hold (útil en una macro).",
 "Aucune icône allumée jusqu'à la fin du prochain combat, pour garder un temps de recharge. Aussi /fhf hold (pratique en macro).",
 "Nenhum ícone aceso até o fim do próximo combate, para guardar uma recarga. Também /fhf hold (útil em uma macro).",
 "다음 전투가 끝날 때까지 아이콘이 켜지지 않습니다. 재사용 대기시간을 아끼고 싶을 때. /fhf hold 도 됩니다 (매크로로 쓰면 편함).",
 "下一场战斗结束前不亮任何图标，用于保留冷却。也可 /fhf hold（适合做成宏）。",
 "下一場戰鬥結束前不亮任何圖示，用於保留冷卻。也可 /fhf hold（適合做成巨集）。")
add("btnOpen", "Open settings", "Einstellungen öffnen", "Открыть настройки", "Abrir ajustes", "Ouvrir les réglages", "Abrir configurações", "설정 열기", "打开设置", "開啟設定")
add("tipOpen",
 "Opens the Full Health Forever settings window (also /fhf config).",
 "Öffnet das Einstellungsfenster von Full Health Forever (auch /fhf config).",
 "Открывает окно настроек Full Health Forever (также /fhf config).",
 "Abre la ventana de ajustes de Full Health Forever (también /fhf config).",
 "Ouvre la fenêtre des réglages de Full Health Forever (aussi /fhf config).",
 "Abre a janela de configurações do Full Health Forever (também /fhf config).",
 "Full Health Forever 설정 창을 엽니다 (/fhf config 도 됨).",
 "打开 Full Health Forever 设置窗口（也可 /fhf config）。",
 "開啟 Full Health Forever 設定視窗（也可 /fhf config）。")

LANGS = ["enUS", "deDE", "ruRU", "esES", "frFR", "ptBR", "koKR", "zhCN", "zhTW"]
def q(s):
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'
out = []
out.append('''local _, ns = ...

-- Every text the addon shows itself. Technical output of /fhf status stays English on purpose
-- (bug reports). esMX falls back to esES.
local strings = {}
''')
for lang in LANGS:
    out.append("strings.%s = {" % lang)
    for k in KEYS:
        out.append("  %s = %s," % (k, q(T[k][lang])))
    out.append("}\n")
out.append('''strings.esMX = setmetatable({}, { __index = strings.esES })

ns.strings = strings

ns.LANGUAGES = {
  { code = "enUS", name = "English" },
  { code = "deDE", name = "Deutsch" },
  { code = "ruRU", name = "Русский" },
  { code = "esES", name = "Español" },
  { code = "frFR", name = "Français" },
  { code = "ptBR", name = "Português (Brasil)" },
  { code = "koKR", name = "한국어" },
  { code = "zhCN", name = "简体中文" },
  { code = "zhTW", name = "繁體中文" },
}

local ALIASES = { enGB = "enUS", ptPT = "ptBR" }
local function Resolve(code)
  code = ALIASES[code] or code
  return strings[code] and code or "enUS"
end

function ns.GameLanguage() return Resolve(GetLocale and GetLocale() or "enUS") end
ns.lang = ns.GameLanguage()

-- code: "auto" (game language) or one of ns.LANGUAGES; texts built before keep their language
-- until /reload
function ns.SetLanguage(code)
  if code == "auto" or not code then ns.lang = ns.GameLanguage() else ns.lang = Resolve(code) end
end

function ns.LanguageName(code)
  for _, l in ipairs(ns.LANGUAGES) do if l.code == code then return l.name end end
  return code
end

ns.L = setmetatable({}, { __index = function(_, k)
  local t = strings[ns.lang]
  return (t and t[k]) or strings.enUS[k]
end })
''')
open(sys.argv[1], "w").write("\n".join(out))
print(len(KEYS), "keys")
