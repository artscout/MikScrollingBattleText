
if (GetLocale() ~= "ruRU") then return end

local L = MikSBT.translations



L.MSG_NEW_PROFILE					= "Новый профиль"
L.MSG_PROFILE_ALREADY_EXISTS		= "Профиль уже существует."
L.MSG_INVALID_PROFILE_NAME			= "Неверное название профиля."
L.MSG_NEW_SCROLL_AREA				= "Новая область прокрутки"
L.MSG_SCROLL_AREA_ALREADY_EXISTS	= "Название области прокрутки уже существует."
L.MSG_INVALID_SCROLL_AREA_NAME		= "Неверное название области прокрутки."
L.MSG_ACKNOWLEDGE_TEXT				= "Вы уверены что хотите выполнить данное действие?"
L.MSG_NORMAL_PREVIEW_TEXT			= "Нормальный"
L.MSG_DISPLAY_QUALITY				= "Показывать оповещение для предметов этого качества."
L.MSG_ITEM_QUALITIES				= "Качество предмета"
L.MSG_ITEMS							= "Предметы"
L.MSG_ITEM_ALREADY_EXISTS			= "Название предмета уже существует."
L.MSG_INVALID_ITEM_NAME				= "Неверное название предмета."



obj = L.TABS
obj["general"]		= { label="Основной", tooltip="Основные настройки."}
obj["scrollAreas"]	= { label="Область прокрутки", tooltip="Настройки областей прокрутки, создание, удаление и т.д.\n\nНаведите мышь на иконки кнопок для большей информации."}
obj["events"]		= { label="События", tooltip="Настройки входящих, исходящих, и извещающих событиях.\n\nНаведите мышь на иконки кнопок для большей информации."}
obj["lootAlerts"]	= { label="Оповещения добычи", tooltip="Настройки отображения оповещений о добыче."}



obj = L.CHECKBOXES

obj["disableMSBTInGroup"]		= { label="Disable MSBT In Group", tooltip="Automatically disable MSBT while in a party or raid."}
obj["enableBlizzardV2CombatText"]= { label="Enable Blizzard Combat Text", tooltip="Enable Blizzard floating combat text damage/healing for player and pet (v2)." }
obj["enableBlizzardV2InGroup"]	= { label="Enable Blizzard Combat Text In Group", tooltip="Only enable Blizzard Combat Text while in a party or raid." }
obj["stickyCrits"]				= { label="Закреплённый крит", tooltip="Отображение критов используя стиль закрепления."}
obj["colorPartialEffects"]		= { label="Цвет частичных эффектов", tooltip="Применяет установленные цвета для частичных эффектов."}
obj["crushing"]					= { label="Сокрушительные удары", tooltip="Отображение трейлера сокрушительных ударов."}
obj["glancing"]					= { label="Скользящие удары", tooltip="Отображение трейлера скользящих ударов."}
obj["absorb"]					= { label="Частичный поглот.", tooltip="Отображение значения частичных поглощении."}
obj["block"]					= { label="Частичный блоки", tooltip="Отображение значения частичных блоков."}
obj["resist"]					= { label="Частичный сопрот.", tooltip="Отображение значения частичной невосприимчивости."}
obj["vulnerability"]			= { label="Бонус уязвимости", tooltip="Отображение значения бонуса уязвимости."}
obj["overheal"]					= { label="Переисциление", tooltip="Отображение значений переисциления."}
obj["overkill"]					= { label="Убийства", tooltip="Отображать значение многократного уничтожения."}
obj["colorDamageAmounts"]		= { label="Цвет урона по значимости", tooltip="Позволяет установить цвета окраски урона по его значимости."}
obj["colorDamageEntry"]			= { tooltip="Вкл/Выкл цвет для этого типа урона."}
obj["colorUnitNames"]			= { label="Окраска имён", tooltip="Применить заданную окраску имён играков/существ."}
obj["colorClassEntry"]			= { tooltip="Включить окраску для этого класа."}
obj["enableScrollArea"]			= { tooltip="Вкл/Выкл область прокрутки."}
obj["inheritField"]				= { label="Перенять", tooltip="Перенять значения полей. Снимите галку для отмены."}
obj["hideSkillIcons"]			= { label="Скрыть иконки", tooltip="Не показывать иконки в этой облости прокрутки."}
obj["stickyEvent"]				= { label="Всегда закреплённый", tooltip="Всегда отображать используя стиль закрепления."}
obj["enableTrigger"]			= { tooltip="Вкл/Выкл триггер."}
obj["allPowerGains"]			= { label="Получ. ВСЕХ энергий", tooltip="Отображение всех получении энергии включая даже те что не отображаются в списке боя.\n\nПРЕДУПРЕЖДЕНИЕ: Эта опция очень спамит и игнорирует все пороги энергии и механику регуляторов.\n\nНЕ РЕКОМЕНДУЕТСЯ."}
obj["abbreviateSkills"]			= { label="Cокращать навыки", tooltip="Cокращать названия навыков (Только английские).\n\nThis can be overriden by each event with the %sl event code."}
obj["mergeSwings"]				= { label="Объединить удары", tooltip="Объединить регулярные удары в ближнем бою, которые ударяют в течение короткого промежутка времени."}
obj["hideSkills"]				= { label="Скрыть навыки", tooltip="Не отображать названия навыков в входящих и исходящих событиях.\n\nYou will give up some customization capability at the event level if you choose to use this option since it causes the %s event code to be ignored."}
obj["hideNames"]				= { label="Скрыть имена", tooltip="Не отображать названия юнитов в входящих и исходящих событиях.\n\nYou will give up some customization capability at the event level if you choose to use this option since it causes the %n event code to be ignored."}
obj["hideFullOverheals"]		= { label="Скрыть избыточное исц.", tooltip="Не показывать исцеление которого эффективное значение лечения равно нулю."}
obj["hideFullHoTOverheals"]		= { label="Скрыть полное избыточное ИзВ", tooltip="Не показывать исцеление за время которого эффективное значение лечения равно нулю."}
obj["hideMergeTrailer"]			= { label="Скрыть трейлер объединенных", tooltip="Не показывать трейлер, который определяет количество попаданий и критов в конце объединенных событий."}
obj["lootedItems"]				= { label="Добыча предметов", tooltip="Выводит оповещение когда вы подбераете предметы."}
obj["moneyGains"]				= { label="Получ. денег", tooltip="Вкл/Выкл оповещение когда вы получаете деньги."}
obj["alwaysShowQuestItems"]		= { label="Предметы заданий", tooltip="Всегда показывать предметы заданий не обращающий внимания на выбор качества."}
obj["enableIcons"]				= { label="Вкл/Выкл иконки навыков", tooltip="Отображение иконок для событий если это возможно и они существуют."}



obj = L.DROPDOWNS
obj["profile"]				= { label="Текущий профиль:", tooltip="Установить текущий профиль."}
obj["normalFont"]			= { label="Шрифт - Обычный:", tooltip="Установить какой будет использоваться шрифт для обычных ударов."}
obj["critFont"]				= { label="Шрифт - Крита:", tooltip="Установить какой будет использоваться шрифт для критов."}
obj["normalOutline"]		= { label="Контур - Обычный:", tooltip="Установить какой будет использоваться стиль контура для обычных ударов."}
obj["critOutline"]			= { label="Контур - Крита:", tooltip="Установить какой будет использоваться стиль контура для критов."}
obj["scrollArea"]			= { label="Область прокрутки:", tooltip="Для настройки выберите желаемую облость прокрутки."}
obj["animationStyle"]		= { label="Стиль анимации:", tooltip="Стиль анимации для не-закрепленной анимации в области прокрутки."}
obj["stickyAnimationStyle"]	= { label="Стиль закрепления:", tooltip="Стиль анимации для закрепления в области прокрутки."}
obj["direction"]			= { label="Направление:", tooltip="Направление анимации."}
obj["behavior"]				= { label="Поведение:", tooltip="Поведение анимации."}
obj["textAlign"]			= { label="Выравнивание текста:", tooltip="Выравнивание текста анимации."}
obj["iconAlign"]			= { label="Выравнивание иконки:", tooltip="Выравнивание иконки способности по отношению к тексту."}
obj["eventCategory"]		= { label="Категория события:", tooltip="Для настройки событий выберите желаемую категорию."}
obj["outputScrollArea"]		= { label="Область вывода:", tooltip="Выберите область прокрутки для вывода информации."}



obj = L.BUTTONS
obj["copyProfile"]				= { label="Скопировать", tooltip="Скопировать профиль в новый профиль с вами установленным названием."}
obj["resetProfile"]				= { label="Сброс", tooltip="Сброс профиля на стандартные установки."}
obj["deleteProfile"]			= { label="Удалить", tooltip="Удалить профиль."}
obj["masterFont"]				= { label="Основной шрифт", tooltip="Позволяет вам установить основной шрифт который будет использоваться всеми областями прокрутки текста боя и всеми событиями, пока не будет изменён в настройках областей и событий."}
obj["partialEffects"]			= { label="Частичные Эффекты", tooltip="Позволяет настроить отображение частичных эффектов"}
obj["damageColors"]				= { label="Цвета урона", tooltip="Позволяет вам установить цвет не взирая на то что установлены цвета по значимости и типу урона на текущий цвет."}
obj["classColors"]				= { label="Окраска классов", tooltip="Позволяет настроить окраску имен игроков/существ в соответствии с их классом." }
obj["inputOkay"]				= { label=OKAY, tooltip="Применить ввод."}
obj["inputCancel"]				= { label=CANCEL, tooltip="Отменить ввод."}
obj["genericSave"]				= { label=SAVE, tooltip="Сохранить изменения."}
obj["genericCancel"]			= { label=CANCEL, tooltip="Отменить изменения."}
obj["addScrollArea"]			= { label="Добавить область", tooltip="Добавить новую область прокрутки, события и триггеры также могут быть установлены на неё."}
obj["configScrollAreas"]		= { label="Настройка области", tooltip="Настройка местонахождения области прокрутки, ширины/высоты прокрутки, выравнивание текста, стиля закрепления анимации и обычного."}
obj["editScrollAreaName"]		= { tooltip="Кликните для редактирования названия области прокрутки."}
obj["scrollAreaFontSettings"]	= { tooltip="Кликните для редактирования настроек шрифта в области прокрутки который будет присвоен всем событиям в этой области прокрутки"}
obj["deleteScrollArea"]			= { tooltip="Кликните для удаление области прокрутки."}
obj["scrollAreasPreview"]		= { label="Предпросмотр", tooltip="Предпросмотр изменений."}
obj["toggleAll"]				= { label="Переключить ВСЕ", tooltip="Вкл/Выкл ВСЕ события в выбранной категории."}
obj["moveAll"]					= { label="Переместить ВСЕ", tooltip="Переместить ВСЕ события в выбранной категории в указанную область прокрутки."}
obj["eventFontSettings"]		= { tooltip="Кликните для редактирования настройки шрифта для события."}
obj["eventSettings"]			= { tooltip="Кликните для редактирования настроек события, области вывода, исходящие сообщения, звуки, и т.д."}
obj["itemsAllowed"]				= { label="Дозволенные предметы", tooltip="Всегда показывать указанные предметы, независимо от качества предмета."}
obj["itemExclusions"]			= { label="Исключение предметов", tooltip="Запрет на отображение, указанных предметов."}
obj["addItem"]					= { label="Добавить предмет", tooltip="Добавить новый предмет в список."}
obj["deleteItem"]				= { tooltip="Нажмите чтобы удалить предмет."}



obj = L.EDITBOXES
obj["copyProfile"]		= { label="Новое название профиля:", tooltip="Название нового профиля в который будет скопирован выбранный профиль."}
obj["partialEffect"]	= { tooltip="Трейлер который будут добавляться при возникновении частичного эффекта."}
obj["scrollAreaName"]	= { label="Новое названия области прокрутки:", tooltip="Новое название для области прокрутки."}
obj["xOffset"]			= { label="X смещение:", tooltip="Смещение по X в выбранной области прокрутки."}
obj["yOffset"]			= { label="Y смещение:", tooltip="Смещение по Y в выбранной области прокрутки."}
obj["eventMessage"]		= { label="Сообщение вывода:", tooltip="Сообщение которое будет отображаться при свершении события."}
obj["iconSkill"]		= { label="Иконка навыка:", tooltip="Название или идентификатор заклинания чья иконка должна отображаться при свершении события.\n\nMSBT будет автоматически пробовать найти подходящую иконку если нет назначенной.\n\nПРИМЕЧАНИЕ: Если навык не может быть найден в книге заклинаний играющего класса в момент свершения событий то идентификатор заклинания должен использоваться вместо названия. Может быть использовано для поиска большинство онлайновых баз данных таких как wowhead."}
obj["itemName"]			= { label="Название предмета:", tooltip="Название добавляемого предмета."}



obj = L.SLIDERS
obj["animationSpeed"]		= { label="Скорость анимации", tooltip="Установка основной скорости анимации.\n\nКаждая область прокрутки также может быть настроена в независимости от основной скорости."}
obj["normalFontSize"]		= { label="Обычный размер шрифта", tooltip="Установка размера шрифта для обычного текста."}
obj["normalFontOpacity"]	= { label="Прозрачность текста", tooltip="Установка прозрачности для обычного текста."}
obj["critFontSize"]			= { label="Размер шрифта Крита", tooltip="Установка размера шрифта для критических ударов."}
obj["critFontOpacity"]		= { label="Прозрачность Крита", tooltip="Установка прозрачности для критических ударов."}
obj["scrollHeight"]			= { label="Высота прокрутки", tooltip="Регулировка высоты области прокрутки."}
obj["scrollWidth"]			= { label="Ширина прокрутки", tooltip="Регулировка ширины области прокрутки."}
obj["scrollAnimationSpeed"]	= { label="Скорость анимации", tooltip="Регулировка скорости анимации в области прокрутки."}
obj["powerThreshold"]		= { label="Порог. вел. энергии", tooltip="Порог величины энергии, привысев который она будет отображаться."}
obj["healThreshold"]		= { label="Порог. вел. исцеления", tooltip="Порог величины исцеления, привысев который она будет отображаться."}
obj["damageThreshold"]		= { label="Порог. вел. урона", tooltip="Порог величины урона, привысев который она будет отображаться."}
obj["dotThrottleTime"]		= { label="Регулятор УзВ", tooltip="Число секунд, чтобы замедлить отображение Урона за Время."}
obj["hotThrottleTime"]		= { label="Регулятор ИзВ", tooltip="Число секунд, чтобы замедлить отображение Исцеления за Время."}
obj["powerThrottleTime"]	= { label="Регулятор времени энергии", tooltip="Число секунд, чтобы замедлить отображение изменения энергии."}


obj = L.EVENT_CATEGORIES
obj[1] = "Входящий - Игрок"
obj[2] = "Входящий - Питомец"
obj[3] = "Исходящий - Игрок"
obj[4] = "Исходящий - Питомец"
obj[5] = "Извещения"



obj = L.EVENT_CODES
obj["DAMAGE_TAKEN"]			= "%a - Значение получаемого урона.\n"
obj["HEALING_TAKEN"]		= "%a - Значение получаемого лечения.\n"
obj["DAMAGE_DONE"]			= "%a - Значение нанесённого урона.\n"
obj["HEALING_DONE"]			= "%a - Значение нанесённого лечения.\n"
obj["ABSORBED_AMOUNT"]		= "%a - Значение поглот. урона.\n"
obj["AURA_AMOUNT"]			= "%a - Значение стеков ауры.\n"
obj["ENERGY_AMOUNT"]		= "%a - Значение энергии.\n"
obj["CP_AMOUNT"]			= "%a - Значение сколько приёмов в серии.\n"
obj["HOLY_POWER_AMOUNT"]	= "%a - Значение вашей энергии Света.\n"
obj["HONOR_AMOUNT"]			= "%a - Значение чести.\n"
obj["REP_AMOUNT"]			= "%a - Значение репутации.\n"
obj["ITEM_AMOUNT"]			= "%a - Значение добытого предмета.\n"
obj["SKILL_AMOUNT"]			= "%a - Значение очков полученного навыка.\n"
obj["EXPERIENCE_AMOUNT"]	= "%a - Значение полученного опыта.\n"
obj["PARTIAL_AMOUNT"]		= "%a - Значение частичного эффекта.\n"
obj["ATTACKER_NAME"]		= "%n - Имя атакующего.\n"
obj["HEALER_NAME"]			= "%n - Имя лекаря.\n"
obj["ATTACKED_NAME"]		= "%n - Имя атакующего юнита.\n"
obj["HEALED_NAME"]			= "%n - Имя исцеляющего юнита.\n"
obj["BUFFED_NAME"]			= "%n - Имя юнита с положительным эффектом.\n"
obj["UNIT_KILLED"]			= "%n - Название убитого юнита.\n"
obj["SKILL_NAME"]			= "%s - Название навыка.\n"
obj["SPELL_NAME"]			= "%s - Название заклинания.\n"
obj["DEBUFF_NAME"]			= "%s - Название отрицательного эффекта.\n"
obj["BUFF_NAME"]			= "%s - Название положительного эффектов\n"
obj["ITEM_BUFF_NAME"]		= "%s - Название предмета с положительным эффектом.\n"
obj["EXTRA_ATTACKS"]		= "%s - Название навыка предоставляющий дополнительную атаку.\n"
obj["SKILL_LONG"]			= "%sl - Длинный от %s. Используется для замены сокращений событий.\n"
obj["DAMAGE_TYPE_TAKEN"]	= "%t - Типа полученного урона.\n"
obj["DAMAGE_TYPE_DONE"]		= "%t - Типа нанесенного урона.\n"
obj["ENVIRONMENTAL_DAMAGE"]	= "%e - Название источника урона (падение, утопление, лава, т.д. и т.п...)\n"
obj["FACTION_NAME"]			= "%e - Название фракции.\n"
obj["EMOTE_TEXT"]			= "%e - Текст эмоций.\n"
obj["MONEY_TEXT"]			= "%e - Текст получения денег.\n"
obj["ITEM_NAME"]			= "%e - Название добытого предмета.\n"
obj["POWER_TYPE"]			= "%p - Тип энергии (энергия, ярость, мана).\n"
obj["TOTAL_ITEMS"]			= "%t - Общее количество добытых предметов в инвентаре."



obj = L.INCOMING_PLAYER_EVENTS
obj["INCOMING_DAMAGE"]						= { label="Ближний удар", tooltip="Вкл/Выкл входящие ближние удары."}
obj["INCOMING_DAMAGE_CRIT"]					= { label="Ближний крит", tooltip="Вкл/Выкл входящие ближние критические удары."}
obj["INCOMING_MISS"]						= { label="Ближний промах", tooltip="Вкл/Выкл входящие ближние промахи."}
obj["INCOMING_DODGE"]						= { label="Ближний уклон.", tooltip="Вкл/Выкл входящие ближние уклонения."}
obj["INCOMING_PARRY"]						= { label="Ближний парир.", tooltip="Вкл/Выкл входящие ближние парирования."}
obj["INCOMING_BLOCK"]						= { label="Ближний блок", tooltip="Вкл/Выкл входящие ближние блоки."}
obj["INCOMING_DEFLECT"]						= { label="Ближний отклон.", tooltip="Вкл/Выкл входящие ближние отклонения."}
obj["INCOMING_ABSORB"]						= { label="Ближний поглот.", tooltip="Вкл/Выкл входящие поглощения ближнего урона."}
obj["INCOMING_IMMUNE"]						= { label="Ближний невоспр.", tooltip="Вкл/Выкл входящий ближний урон к которому вы невосприимчевы."}
obj["INCOMING_SPELL_DAMAGE"]				= { label="Удар заклинания", tooltip="Вкл/Выкл входящие удары заклинания."}
obj["INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Крит заклинания", tooltip="Вкл/Выкл входящие критические удары заклинания."}
obj["INCOMING_SPELL_DOT"]					= { label="УзВ заклинания", tooltip="Вкл/Выкл входящий урон за время заклинанием."}
obj["INCOMING_SPELL_DOT_CRIT"]				= { label="Крит УзВ", tooltip="Вкл/Выкл входящий крит урона за время."}
obj["INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Удары Ранящиего щита", tooltip="Вкл/Выкл входящий урон Ранящиего щита."}
obj["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Криты Ранящего щита", tooltip="Вкл/Выкл входящий крит Ранящего щита."}
obj["INCOMING_SPELL_MISS"]					= { label="Промах заклинания", tooltip="Вкл/Выкл входящие промахи заклинания."}
obj["INCOMING_SPELL_DODGE"]					= { label="Уклон. заклинания", tooltip="Вкл/Выкл входящие уклонения от заклинания."}
obj["INCOMING_SPELL_PARRY"]					= { label="Парир. заклинания", tooltip="Вкл/Выкл входящие парирования заклинания."}
obj["INCOMING_SPELL_BLOCK"]					= { label="Блок заклинания", tooltip="Вкл/Выкл входящие блоки заклинания."}
obj["INCOMING_SPELL_DEFLECT"]				= { label="Отклон заклинания", tooltip="Вкл/Выкл входящие отклонения заклинания."}
obj["INCOMING_SPELL_RESIST"]				= { label="Сопрот. Заклинания", tooltip="Вкл/Выкл входящие сопротивления заклинания."}
obj["INCOMING_SPELL_ABSORB"]				= { label="Поглот. Заклинания", tooltip="Вкл/Выкл входящие поглощения урона от нанесённых вам заклинаний."}
obj["INCOMING_SPELL_IMMUNE"]				= { label="Невоспр. Заклинания", tooltip="Вкл/Выкл входящий урон от заклинаний к которому вы невосприимчевы."}
obj["INCOMING_SPELL_REFLECT"]				= { label="Отраж. Заклинания", tooltip="Вкл/Выкл входящий урон заклинаний которые вы отразили."}
obj["INCOMING_SPELL_INTERRUPT"]				= { label="Прерв. Заклинания", tooltip="Вкл/Выкл входящие прерывания заклинаний."}
obj["INCOMING_HEAL"]						= { label="Исцеление", tooltip="Вкл/Выкл входящие исцеления."}
obj["INCOMING_HEAL_CRIT"]					= { label="Крит исцеления", tooltip="Вкл/Выкл входящие критические исцеления."}
obj["INCOMING_HOT"]							= { label="Исцеление за Время", tooltip="Вкл/Выкл входящие Исцеление за Время."}
obj["INCOMING_HOT_CRIT"]					= { label="Крит исцеление за время", tooltip="Вкл/Выкл входящий крит Исцеление за Время."}
obj["INCOMING_ENVIRONMENTAL"]				= { label="Урон окружающей среды", tooltip="Урон окружающей среды (Падение, Утопление, Лава, т.д. и т.п...)."}

obj = L.INCOMING_PET_EVENTS
obj["PET_INCOMING_DAMAGE"]						= { label="Ближний удар", tooltip="Вкл/Выкл вашего питомца входящие ближние удары."}
obj["PET_INCOMING_DAMAGE_CRIT"]					= { label="Ближний крит", tooltip="Вкл/Выкл вашего питомца входящие ближние критические удары."}
obj["PET_INCOMING_MISS"]						= { label="Ближний промах", tooltip="Вкл/Выкл вашего питомца входящие ближние промахи."}
obj["PET_INCOMING_DODGE"]						= { label="Ближний уклон.", tooltip="Вкл/Выкл вашего питомца входящие ближние уклонения."}
obj["PET_INCOMING_PARRY"]						= { label="Ближний парир.", tooltip="Вкл/Выкл вашего питомца входящие ближние парирования."}
obj["PET_INCOMING_BLOCK"]						= { label="Ближний блок", tooltip="Вкл/Выкл вашего питомца входящие ближние блоки."}
obj["PET_INCOMING_DEFLECT"]						= { label="Ближний отклон.", tooltip="Вкл/Выкл вашего питомца входящие ближние отклонения."}
obj["PET_INCOMING_ABSORB"]						= { label="Ближний поглот.", tooltip="Вкл/Выкл поглощения вашем питомцем входящего ближнего урона."}
obj["PET_INCOMING_IMMUNE"]						= { label="Ближний невоспр.", tooltip="Вкл/Выкл входящий ближний урон к которому имуннен питомец."}
obj["PET_INCOMING_SPELL_DAMAGE"]				= { label="Удар заклинания", tooltip="Вкл/Выкл вашего питомца входящие удары заклинания."}
obj["PET_INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Крит заклинания", tooltip="Вкл/Выкл вашего питомца входящие критические удары заклинания."}
obj["PET_INCOMING_SPELL_DOT"]					= { label="УзВ заклинания", tooltip="Вкл/Выкл вашего питомца входящий урон за время заклинанием."}
obj["PET_INCOMING_SPELL_DOT_CRIT"]				= { label="Крит УзВ", tooltip="Вкл/Выкл входящий крит урона за время."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Удары ранящего щита", tooltip="Вкл/Выкл входящий урон по вашему питомцу от Ранящего щита."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Криты ранящиего щита", tooltip="Вкл/Выкл входящий крит по вашему питомцу от Ранящиего щита."}
obj["PET_INCOMING_SPELL_MISS"]					= { label="Промах заклинания", tooltip="Вкл/Выкл вашего питомца входящие промахи заклинания."}
obj["PET_INCOMING_SPELL_DODGE"]					= { label="Уклон. заклинания", tooltip="Вкл/Выкл вашего питомца входящие уклонения от заклинания."}
obj["PET_INCOMING_SPELL_PARRY"]					= { label="Парир. заклинания", tooltip="Вкл/Выкл вашего питомца входящие парирования заклинания."}
obj["PET_INCOMING_SPELL_BLOCK"]					= { label="Блок Заклинания", tooltip="Вкл/Выкл вашего питомца входящие блоки заклинания."}
obj["PET_INCOMING_SPELL_DEFLECT"]				= { label="Отклон заклинания", tooltip="Вкл/Выкл вашего питомца входящие отклонения заклинания."}
obj["PET_INCOMING_SPELL_RESIST"]				= { label="Сопрот. Заклинания", tooltip="Вкл/Выкл вашего питомца входящие сопротивления заклинания."}
obj["PET_INCOMING_SPELL_ABSORB"]				= { label="Поглот. Заклинания", tooltip="Вкл/Выкл поглощения урона вашим питомцем от входящих заклинаний."}
obj["PET_INCOMING_SPELL_IMMUNE"]				= { label="Невоспр. Заклинания", tooltip="Вкл/Выкл входящий урон от заклинаний к которому невосприимчив ваш питомец."}
obj["PET_INCOMING_HEAL"]						= { label="Исцеление", tooltip="Вкл/Выкл вашего питомца входящие исцеления."}
obj["PET_INCOMING_HEAL_CRIT"]					= { label="Крит исцеления", tooltip="Вкл/Выкл вашего питомца входящие критические исцеления."}
obj["PET_INCOMING_HOT"]							= { label="Исцеление за Время", tooltip="Вкл/Выкл вашего питомца входящие исцеления за время."}
obj["PET_INCOMING_HOT_CRIT"]					= { label="Крит исцеление за время", tooltip="Вкл/Выкл вашего питомца входящий крит Исцеление за Время."}



obj = L.OUTGOING_PLAYER_EVENTS
obj["OUTGOING_DAMAGE"]						= { label="Ближний удар", tooltip="Вкл/Выкл исходящие ближние удары."}
obj["OUTGOING_DAMAGE_CRIT"]					= { label="Ближний крит", tooltip="Вкл/Выкл исходящие ближние критические удары."}
obj["OUTGOING_MISS"]						= { label="Ближний промах", tooltip="Вкл/Выкл исходящие ближние промахи."}
obj["OUTGOING_DODGE"]						= { label="Ближний уклон.", tooltip="Вкл/Выкл исходящие ближние уклонения."}
obj["OUTGOING_PARRY"]						= { label="Ближний парир.", tooltip="Вкл/Выкл исходящие ближние парирования."}
obj["OUTGOING_BLOCK"]						= { label="Ближний блок", tooltip="Вкл/Выкл исходящие ближние блоки."}
obj["OUTGOING_DEFLECT"]						= { label="Ближний отклон.", tooltip="Вкл/Выкл исходящие ближние отклонения."}
obj["OUTGOING_ABSORB"]						= { label="Ближний поглот.", tooltip="Вкл/Выкл исходящие поглощения ближнего урона."}
obj["OUTGOING_IMMUNE"]						= { label="Ближний невоспр.", tooltip="Вкл/Выкл исходящий ближний урон когда враг невосприимчив к нему."}
obj["OUTGOING_EVADE"]						= { label="Ближний 'Мимо'", tooltip="Вкл/Выкль исходящие ближние evades."}
obj["OUTGOING_SPELL_DAMAGE"]				= { label="Удар заклинания", tooltip="Вкл/Выкл исходящие удары заклинаний."}
obj["OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Крит заклинания", tooltip="Вкл/Выкл исходящие критические удары заклинаний."}
obj["OUTGOING_SPELL_DOT"]					= { label="УзВ заклинания", tooltip="Вкл/Выкл исходящий урон за время заклинания."}
obj["OUTGOING_SPELL_DOT_CRIT"]				= { label="Крит УзВ", tooltip="Вкл/Выкл исходящий крит урона за время."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Удары ранящего щита", tooltip="Вкл/Выкл исходящий урон от Ранящего щита."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Криты ранящего щита", tooltip="Вкл/Выкл исходящий крит от Ранящего щита."}
obj["OUTGOING_SPELL_MISS"]					= { label="Промах заклинания", tooltip="Вкл/Выкл исходящие промахи заклинаний."}
obj["OUTGOING_SPELL_DODGE"]					= { label="Уклон. Заклинания", tooltip="Вкл/Выкл исходящие уклонения от заклинаний."}
obj["OUTGOING_SPELL_PARRY"]					= { label="Парир. Заклинания", tooltip="Вкл/Выкл исходящие парирования заклинаний."}
obj["OUTGOING_SPELL_BLOCK"]					= { label="Блок Заклинания", tooltip="Вкл/Выкл исходящие блокирование заклинаний."}
obj["OUTGOING_SPELL_DEFLECT"]				= { label="Отклон заклинания", tooltip="Вкл/Выкл исходящие отклонения заклинания."}
obj["OUTGOING_SPELL_RESIST"]				= { label="Сопрот. заклинания", tooltip="Вкл/Выкл исходящие сопротивление заклинаниям."}
obj["OUTGOING_SPELL_ABSORB"]				= { label="Поглот. заклинания", tooltip="Вкл/Выкл исходящие поглощения урона от исходящих заклинаний."}
obj["OUTGOING_SPELL_IMMUNE"]				= { label="Невоспр. заклинания", tooltip="Вкл/Выкл исходящий урон заклинаний когда враг невосприимчив к нему."}
obj["OUTGOING_SPELL_REFLECT"]				= { label="Отраж. заклинания", tooltip="Вкл/Выкл исходящий урон заклинаний отраженный назад на вас."}
obj["OUTGOING_SPELL_INTERRUPT"]				= { label="Прерывание заклинания", tooltip="Вкл/Выкл исходящие прерывания заклинаний."}
obj["OUTGOING_SPELL_EVADE"]					= { label="'Мимо' заклинания", tooltip="Вкл/Выкл исходящие 'Мимо' Заклинаний."}
obj["OUTGOING_HEAL"]						= { label="Исцеление", tooltip="Вкл/Выкл исходящие исцеления."}
obj["OUTGOING_HEAL_CRIT"]					= { label="Крит исцеления", tooltip="Вкл/Выкл исходящие критические исцеления."}
obj["OUTGOING_HOT"]							= { label="Исцеление за Время", tooltip="Вкл/Выкл исходящие исцеления за время."}
obj["OUTGOING_HOT_CRIT"]					= { label="Крит исцеление за время", tooltip="Вкл/Выкл исходящий крит исцеления за время."}
obj["OUTGOING_DISPEL"]						= { label="Рассеивания", tooltip="Вкл/Выкл исходящие рассеивания."}

obj = L.OUTGOING_PET_EVENTS
obj["PET_OUTGOING_DAMAGE"]						= { label="Ближний удар", tooltip="Вкл/Выкл вашего питомца исходящие ближние удары."}
obj["PET_OUTGOING_DAMAGE_CRIT"]					= { label="Ближний крит", tooltip="Вкл/Выкл вашего питомца исходящие ближние критические удары."}
obj["PET_OUTGOING_MISS"]						= { label="Ближний промах", tooltip="Вкл/Выкл вашего питомца исходящие ближние промахи."}
obj["PET_OUTGOING_DODGE"]						= { label="Ближний уклон.", tooltip="Вкл/Выкл вашего питомца исходящие ближние уклонения."}
obj["PET_OUTGOING_PARRY"]						= { label="Ближний парир.", tooltip="Вкл/Выкл вашего питомца исходящие ближние парирования."}
obj["PET_OUTGOING_BLOCK"]						= { label="Ближний блок", tooltip="Вкл/Выкл вашего питомца исходящие ближние блоки."}
obj["PET_OUTGOING_DEFLECT"]						= { label="Ближний отклон.", tooltip="Вкл/Выкл вашего питомца исходящие ближние отклонения."}
obj["PET_OUTGOING_ABSORB"]						= { label="Ближний поглот.", tooltip="Вкл/Выкл вашего питомца исходящие поглощения ближнего урона."}
obj["PET_OUTGOING_IMMUNE"]						= { label="Ближний невоспр.", tooltip="Вкл/Выкл вашего питомца исходящие ближней урон к которому невосприимчив враг."}
obj["PET_OUTGOING_EVADE"]						= { label="Ближний 'Мимо'", tooltip="Вкл/Выкл вашего питомца исходящие ближние 'Мимо'."}
obj["PET_OUTGOING_SPELL_DAMAGE"]				= { label="Удар заклинания", tooltip="Вкл/Выкл вашего питомца исходящие удары заклинаний."}
obj["PET_OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Крит заклинания", tooltip="Вкл/Выкл вашего питомца исходящие критические удары заклинаний."}
obj["PET_OUTGOING_SPELL_DOT"]					= { label="УзВ заклинания", tooltip="Вкл/Выкл исходящие заклинания наносящие урон за время."}
obj["PET_OUTGOING_SPELL_DOT_CRIT"]				= { label="Крит УзВ", tooltip="Вкл/Выкл исходящий крит урона за время."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Удары ранящего щита", tooltip="Вкл/Выкл исходящий урот вашего питомца от Ранящего щита."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Криты ранящего щита", tooltip="Вкл/Выкл исходящий крит вашего питомца от Ранящего щита.."}
obj["PET_OUTGOING_SPELL_MISS"]					= { label="Промах заклинания", tooltip="Вкл/Выкл вашего питомца исходящие промахи заклинаний."}
obj["PET_OUTGOING_SPELL_DODGE"]					= { label="Уклон. заклинания", tooltip="Вкл/Выкл вашего питомца исходящие уклонения от заклинаний."}
obj["PET_OUTGOING_SPELL_PARRY"]					= { label="Парир. заклинания", tooltip="Вкл/Выкл вашего питомца исходящие парирования заклинаний."}
obj["PET_OUTGOING_SPELL_BLOCK"]					= { label="Блок заклинания", tooltip="Вкл/Выкл вашего питомца исходящие блокирование заклинаний."}
obj["PET_OUTGOING_SPELL_DEFLECT"]				= { label="Отклон заклинания", tooltip="Вкл/Выкл вашего питомца исходящие отклонения заклинания."}
obj["PET_OUTGOING_SPELL_RESIST"]				= { label="Сопрот. заклинания", tooltip="Вкл/Выкл вашего питомца исходящие сопротивление заклинаниям."}
obj["PET_OUTGOING_SPELL_ABSORB"]				= { label="Поглот. заклинания", tooltip="Вкл/Выкл исходящие поглощения урона от исходящих заклинаний."}
obj["PET_OUTGOING_SPELL_IMMUNE"]				= { label="Невоспр. заклинания", tooltip="Вкл/Выкл исходящий урон от заклинаний к которому невосприимчив враг."}
obj["PET_OUTGOING_SPELL_EVADE"]					= { label="'Мимо' заклинаний", tooltip="Вкл/Выкл исходящие 'Мимо' Заклинаний."}
obj["PET_OUTGOING_HEAL"]						= { label="Исцеление", tooltip="Вкл/Выкл исходящие исцеления питомца."}
obj["PET_OUTGOING_HEAL_CRIT"]					= { label="Крит исцеления", tooltip="Вкл/Выкл исходящие критические исцеления питомца."}
obj["PET_OUTGOING_HOT"]							= { label="Исцеление за Время", tooltip="Вкл/Выкл исходящие исцеления за время питомца."}
obj["PET_OUTGOING_HOT_CRIT"]					= { label="Крит исцеление за время", tooltip="Вкл/Выкл исходящий крит исцеления за время питомца."}
obj["PET_OUTGOING_DISPEL"]						= { label="Рассеивания", tooltip="Вкл/Выкл исходящие рассеивания"}



obj = L.NOTIFICATION_EVENTS
obj["NOTIFICATION_DEBUFF"]				= { label="Отриц. эффекты", tooltip="Вкл/Выкл оповещение о заражении отрицательными эффектами."}
obj["NOTIFICATION_DEBUFF_STACK"]		= { label="Стаки дебаффа", tooltip="Включить оповещение сколькими стаками отрицательных эффектов вы поражены."}
obj["NOTIFICATION_BUFF"]				= { label="Полож. эффекты", tooltip="Вкл/Выкл оповещение о получении положительных эффектов."}
obj["NOTIFICATION_BUFF_STACK"]			= { label="Стаки баффа", tooltip="Включить оповещение сколько стаков положительного эффектка вы получили."}
obj["NOTIFICATION_ITEM_BUFF"]			= { label="Полож. эффекты Предметов", tooltip="Вкл/Выкл оповещение о положительных эффектах полученных вашими предметами."}
obj["NOTIFICATION_DEBUFF_FADE"]			= { label="Пропад. отриц. эффектов", tooltip="Вкл/Выкл оповещение о пропадание с вас отрицательных эффектов."}
obj["NOTIFICATION_BUFF_FADE"]			= { label="Пропад. полож. эффектов", tooltip="Вкл/Выкл оповещение о пропадание с вас положительных эффектов."}
obj["NOTIFICATION_ITEM_BUFF_FADE"]		= { label="Пропад. полож. эф. предметов", tooltip="Вкл/Выкл оповещение о пропадание с предметов положительных эффектов."}
obj["NOTIFICATION_COMBAT_ENTER"]		= { label="Начало боя", tooltip="Вкл/Выкл оповещение о том когда вы начинаете бой."}
obj["NOTIFICATION_COMBAT_LEAVE"]		= { label="Выход из боя", tooltip="Вкл/Выкл оповещение о том когда вы выходите из бой."}
obj["NOTIFICATION_POWER_GAIN"]			= { label="Получ. энергии", tooltip="Вкл/Выкл оповещение когда вы получаете дополнительную ману, ярость, или энергию."}
obj["NOTIFICATION_POWER_LOSS"]			= { label="Потеря энергии", tooltip="Вкл/Выкл оповещение когда теряете ману, ярость, или энергию от похищения."}
obj["NOTIFICATION_CP_GAIN"]				= { label="Получ. Приёма в Серии", tooltip="Вкл/Выкл оповещение когда вы получаете приём в серии."}
obj["NOTIFICATION_CP_FULL"]				= { label="Макс. Приёмов в Серии", tooltip="Вкл/Выкл оповещение когда вы достигаете максимального количества приемов в серии."}
obj["NOTIFICATION_HOLY_POWER_CHANGE"]	= { label="Изменение энергии Света", tooltip="Вкл/Выкл оповещение изменения вашей энергии Света."}
obj["NOTIFICATION_HOLY_POWER_FULL"]		= { label="Полная энергия Света", tooltip="Вкл/Выкл оповещение когда вы достигаете полной энергии Света."}
obj["NOTIFICATION_HONOR_GAIN"]			= { label="Получ. чести", tooltip="Вкл/Выкл оповещение когда вы получаете очки чести."}
obj["NOTIFICATION_REP_GAIN"]			= { label="Получ. репутации", tooltip="Вкл/Выкл оповещение когда вы получаете очки репутации."}
obj["NOTIFICATION_REP_LOSS"]			= { label="Потеря репутации", tooltip="Вкл/Выкл оповещение когда вы теряете очки репутации."}
obj["NOTIFICATION_SKILL_GAIN"]			= { label="Получ. навыков", tooltip="Вкл/Выкл оповещение когда вы получаете очки к навыку."}
obj["NOTIFICATION_EXPERIENCE_GAIN"]		= { label="Получ. опыта", tooltip="Вкл/Выкл оповещение когда вы получаете очки опыта."}
obj["NOTIFICATION_PC_KILLING_BLOW"]		= { label="Игрока победный удар", tooltip="Вкл/Выкл оповещение когда вы рядом с враждебным игроком получаете Победный удар."}
obj["NOTIFICATION_NPC_KILLING_BLOW"]	= { label="Победный удар НИПа", tooltip="Вкл/Выкл оповещение когда вы рядом с НИПом получаете Победный удар."}
obj["NOTIFICATION_EXTRA_ATTACK"]		= { label="Экстра атаки", tooltip="Вкл/Выкл оповещение когда вы получаете дополнительные атаки такие как Оружие неистовства ветра, Специализация на владении мечами, и т.д."}
obj["NOTIFICATION_ENEMY_BUFF"]			= { label="Получ. врагом полож. эффектов", tooltip="Вкл/Выкл оповещение о получении положительных эффектов вашей текущей враждебной цели."}
obj["NOTIFICATION_MONSTER_EMOTE"]		= { label="Эмоции монстров", tooltip="Вкл/Выкл эмоции монстров которые в текущий момент в цели."}



obj = L.OUTLINES
obj[1] = "Нету"
obj[2] = "Тонкий"
obj[3] = "Жирный"

obj = L.TEXT_ALIGNS
obj[1] = "Влево"
obj[2] = "По центру"
obj[3] = "Вправо"






obj = L.ANIMATION_STYLE_DATA
obj["Angled"]		= "Угловой"
obj["Horizontal"]	= "Горизонтальный"
obj["Parabola"]		= "Парабола"
obj["Straight"]		= "Прямой"
obj["Static"]		= "Статика"
obj["Pow"]			= "Ручеёк"

obj["Alternate"]	= "Чередоваться"
obj["Left"]			= "Влево"
obj["Right"]		= "Вправо"
obj["Up"]			= "Вверх"
obj["Down"]			= "Вниз"

obj["AngleUp"]			= "Угол вверх"
obj["AngleDown"]		= "Угол вниз"
obj["GrowUp"]			= "Увеличиваться"
obj["GrowDown"]			= "Уменьшаться"
obj["CurvedLeft"]		= "Изогнутый влево"
obj["CurvedRight"]		= "Изогнутый вправо"
obj["Jiggle"]			= "Тряска"
obj["Normal"]			= "Нормальный"

L.MSG_INVALID_CUSTOM_SOUND_NAME		= "Неверное название звукового файла."
L.MSG_SOUND_NAME_ALREADY_EXISTS		= "Название звукового файла уже существует."
L.MSG_INVALID_SOUND_FILE			= "Звуки должны быть в .ogg формате."
L.CHECKBOXES["enableSounds"]				= { label="Вкл/Выкл звуки", tooltip="Проигрывать звуки заданные в событиях и триггерах."}
L.DROPDOWNS["sound"]				= { label="Звук:", tooltip="Выберите какой проигрывать звук при выполнении события."}
L.BUTTONS["addCustomSound"]			= { label="Добавить звук", tooltip="Добовляет пользовательский звук к списку доступных звуков.\n\nWARNING: Файл звука должен находиться в целевой деректории *ДО* запуска WoW.\n\nНастоятельно рекомендуется поместить файл в директорию звуков MikScrollingBattleText\\чтобы избежать проблем."}
L.BUTTONS["customSound"]				= { tooltip="Кликните для вставки пользовательского звукового файла." }
L.BUTTONS["playSound"]				= { label="Воспр.", tooltip="Нажмите для воспроизведения выбранного звука."}
L.EDITBOXES["customSoundName"]	= { label="Звук:", tooltip="Название, используемое для определения звука.\n\nПример: Мой Звук"}
L.EDITBOXES["customSoundPath"]	= { label="Путь к звуку:", tooltip="Путь к файлу звука.\n\nNOTE: Если файл находится в рекомендованном директории звуков\\MikScrollingBattleText, тогда впишите только названия файла, вместо полного пути.\n\nExample: мойЗвук.ogg "}
L.EDITBOXES["soundFile"]		= { label="Звуковой файл:", tooltip="Название звукового файла который будет проигрываться при свершении события."}
