
if (GetLocale() ~= "deDE") then return end

local L = MikSBT.translations



L.MSG_NEW_PROFILE					= "Neues Profil"
L.MSG_PROFILE_ALREADY_EXISTS		= "Profil existiert bereits."
L.MSG_INVALID_PROFILE_NAME			= "Ungültiger Profilname."
L.MSG_NEW_SCROLL_AREA				= "Neuer Scroll-Bereich"
L.MSG_SCROLL_AREA_ALREADY_EXISTS	= "Name für Scroll-Bereich existiert bereits."
L.MSG_INVALID_SCROLL_AREA_NAME		= "Ungültiger Name für Scroll-Bereich."
L.MSG_ACKNOWLEDGE_TEXT				= "Bist du sicher, dass du diese Aktion durchführen willst?"
L.MSG_NORMAL_PREVIEW_TEXT			= "Normal"
L.MSG_DISPLAY_QUALITY				= "Zeige Benachrichtigungen für Gegenstände dieser Qualtität."
L.MSG_ITEM_QUALITIES				= "Gegenstandsqualitäten"
L.MSG_ITEMS							= "Gegenstände"
L.MSG_ITEM_ALREADY_EXISTS			= "Gegenstandsname exisiert bereits."
L.MSG_INVALID_ITEM_NAME				= "Ungültiger Gegenstandsname."



obj = L.TABS
obj["general"]		= { label="Allgemein", tooltip="Allgemeine Optionen anzeigen."}
obj["scrollAreas"]	= { label="Scroll-Bereiche", tooltip="Optionen für das Erstellen, Löschen, und Konfigurieren der Scroll-Bereiche anzeigen.\n\nFür mehr Informationen mit der Maus über die Symbole fahren."}
obj["events"]		= { label="Ereignisse", tooltip="Optionen für eingehende, ausgehende und benachrichtigende Ereignisse anzeigen.\n\nFür mehr Informationen mit der Maus über die Symbole fahren."}
obj["lootAlerts"]	= { label="Plündernachrichten", tooltip="Optionen für die Plünderbenachrichtigung anzeigen."}



obj = L.CHECKBOXES
obj["enableMSBT"]				= { label="Mik's Scrolling Battle Text aktivieren", tooltip="MSBT aktivieren."}
obj["disableMSBTInGroup"]		= { label="MSBT in Gruppen deaktivieren", tooltip="MSBT automatisch in Gruppe oder Schlachtzug deaktivieren."}
obj["enableBlizzardV2CombatText"]= { label="Blizzard-Kampftext aktivieren", tooltip="Blizzard Kampftext (v2) fuer Spieler und Begleiter aktivieren." }
obj["enableBlizzardV2InGroup"]	= { label="Blizzard-Kampftext in Gruppen", tooltip="Blizzard Kampftext nur in Gruppe oder Schlachtzug aktivieren." }
obj["stickyCrits"]				= { label="Sticky-Krits", tooltip="Bei kritischen Treffern den 'Sticky'-Stil verwenden."}
obj["colorPartialEffects"]		= { label="Teileffekte einfärben", tooltip="Fügt den Teileffekten festgelegte Farben hinzu."}
obj["crushing"]					= { label="Schmetternde Stöße", tooltip="Zeigt den Anhang bei schmetternden Treffern an."}
obj["glancing"]					= { label="Streifende Treffer", tooltip="Zeigt den Anhang bei streifenden Treffern an."}
obj["absorb"]					= { label="Teilweise absorbiert", tooltip="Zeigt die zum Teil absobierte Menge an."}
obj["block"]					= { label="Teilweise geblockt", tooltip="Zeigt die zum Teil geblockte Menge an."}
obj["resist"]					= { label="Teilweise widerstanden", tooltip="Zeigt die zum Teil widerstandene Menge an."}
obj["vulnerability"]			= { label="Verwundbarkeitsboni", tooltip="Zeigt die Menge der Verwundbarkeitsboni an."}
obj["overheal"]					= { label="Überheilung", tooltip="Zeigt die Menge der Überheilung an."}
obj["overkill"]					= { label="Über Tod", tooltip="Zeigt die Menge des Schadens über Tod an."}
obj["colorDamageAmounts"]		= { label="Farbiger Schaden", tooltip="Färbt den Schaden in der entsprechenden Farbe ein."}
obj["colorDamageEntry"]			= { tooltip="Aktiviert Farbe für diese Schadensart."}
obj["colorUnitNames"]			= { label="Farbige Namen", tooltip="Färbt die Namen in Klassenfarbe ein."}
obj["colorClassEntry"]			= { tooltip="Aktiviert Farbe für diese Klasse."}
obj["enableScrollArea"]			= { tooltip="Scroll-Bereich aktivieren."}
obj["inheritField"]				= { label="Übernehmen", tooltip="Übernimmt die eingegebenen Werte.\n\nHacken entfernen, um zu überschreiben."}
obj["hideSkillIcons"]			= { label="Symbole verstecken", tooltip="Keine Symbole in diesem Scroll-Bereich anzeigen."}
obj["stickyEvent"]				= { label="Sticky-Stil verwenden", tooltip="Ereignis immer im 'Sticky'-Stil anzeigen."}
obj["enableTrigger"]			= { tooltip="Auslöser aktivieren."}
obj["allPowerGains"]			= { label="ALLE Regenerationen", tooltip="Zeigt alle Ressourcenregenerationen einschließlich derjenigen, die nicht im Kampflog gemeldet werden.\n\nWARNUNG: Diese Einstellung führt zu viel Spam, da sie alle Grenzwerte und Drosselfunktionen ignoriert.\n\nNICHT EMPFOHLEN."}
obj["abbreviateSkills"]			= { label="Fähigkeiten abkürzen", tooltip="Fähigkeiten abkürzen (nur Englisch).\n\nDies kann von jedem Ereignis mit dem %sl Code überschrieben werden."}
obj["mergeSwings"]				= { label="Schwünge verbinden", tooltip="Verbindet normale Meleetreffer, die in einer kurzen Zeitspanne erfolgen."}
obj["hideSkills"]				= { label="Fähigkeiten verstecken", tooltip="Keine Fähigkeitsnamen für eingehende und ausgehende Ereignisse anzeigen.\n\nDu gibst ein wenig Anpassungsmöglichkeit auf Ereignisebene auf, da der Ereigniscode %s nun ignoriert wird."}
obj["hideNames"]				= { label="Namen verstecken", tooltip="Keine Namen für eingehende und ausgehende Ereignisse anzeigen.\n\nDu gibst ein wenig Anpassungsmöglichkeit auf Ereignisebene auf, da der Ereigniscode %n nun ignoriert wird."}
obj["hideFullOverheals"]		= { label="Überheilungen verstecken", tooltip="Heilungen, die eine effektive Heilung von null haben, werden nicht angezeigt."}
obj["hideFullHoTOverheals"]		= { label="HoT Überheilungen verstecken", tooltip="Heilungen über Zeit, die eine effektive Heilung von null haben, werden nicht angezeigt."}
obj["hideMergeTrailer"]			= { label="Verbinden-Anhang verstecken", tooltip="Der Anhang, der die Anzahl der miteinander verbundenen Treffer und Krits am Ende jedes Ereignisses darstellt, wird nicht angezeigt."}
obj["lootedItems"]				= { label="Geplünderte Gegenstände", tooltip="Zeigt Benachrichtigungen, wenn Gegenstände geplündert wurden."}
obj["moneyGains"]				= { label="Gold erhalten", tooltip="Zeigt Benachrichtigungen, wenn Gold erhalten wurde."}
obj["alwaysShowQuestItems"]		= { label="Questgegenstände immer anzeigen", tooltip="Questgegenstände immer anzeigen, unabhängig der ausgewählten Qualitäten."}
obj["enableIcons"]				= { label="Fähigkeitssymbole aktivieren", tooltip="Zeigt, wenn möglich, Symbole für Ereignisse an."}



obj = L.DROPDOWNS
obj["profile"]				= { label="Aktuelles Profil:", tooltip="Legt das aktuelle Profil fest."}
obj["normalFont"]			= { label="Schrift - Normal:", tooltip="Legt die Schriftart für nicht-kritische Treffer."}
obj["critFont"]				= { label="Schrift - Kritisch:", tooltip="Legt die Schriftart für kritische Treffer."}
obj["normalOutline"]		= { label="Kontur - Normal:", tooltip="Legt die Kontur für nicht-kritische Treffer."}
obj["critOutline"]			= { label="Kontur - Kritisch:", tooltip="Legt die Kontur für kritische Treffer."}
obj["scrollArea"]			= { label="Scroll-Bereich:", tooltip="Wählt den zu konfigurierenden Scroll-Bereich aus."}
obj["animationStyle"]		= { label="Animationen:", tooltip="Der Animationsstil für Nicht-'Sticky'-Animationen in dem Scroll-Bereich."}
obj["stickyAnimationStyle"]	= { label="Sticky Animationen:", tooltip="Der Animationsstil für 'Sticky'-Animationen in dem Scroll-Bereich."}
obj["direction"]			= { label="Richtung:", tooltip="Die Richtung der Animation."}
obj["behavior"]				= { label="Verhalten:", tooltip="Das Verhalten der Animation."}
obj["textAlign"]			= { label="Text ausrichten:", tooltip="Die Ausrichtung des Textes für die Animation."}
obj["iconAlign"]			= { label="Symbol ausrichten:", tooltip="Die Ausrichtung des Symbols für die Animation."}
obj["eventCategory"]		= { label="Ereigniskategorie:", tooltip="Die Kategorie der zu konfigurienden Ereignisse."}
obj["outputScrollArea"]		= { label="Scroll-Bereich:", tooltip="Den Scroll-Bereich für die Textausgabe auswählen."}



obj = L.BUTTONS
obj["copyProfile"]				= { label="Kopieren", tooltip="Kopiert das aktuelle Profil auf ein neues Profil, dessen Namen du selbst bestimmst."}
obj["resetProfile"]				= { label="Zurücksetzen", tooltip="Setzt das Profil auf die Standardeinstellungen zurück."}
obj["deleteProfile"]			= { label="Löschen", tooltip="Löscht das Profil."}
obj["masterFont"]				= { label="Master Schrift", tooltip="Erlaubt dir die Master Schrift festzulegen, welche bei allen Scroll-Bereichen und Ereignissen übernommen wird, sofern sie nicht überschrieben wird."}
obj["partialEffects"]			= { label="Partielle Effekte", tooltip="Erlaubt dir festzulegen, welche partiellen Effekte angezeigt werden sollen, ob sie eingefärbt werden sollen, und wenn ja in welcher Farbe."}
obj["damageColors"]				= { label="Schaden Farben", tooltip="Erlaubt dir festzulegen, ob oder auch nicht die Beträge nach der Farbe der Schadensart gefärbt sind und welche Farben für jede Art verwendet werden."}
obj["classColors"]				= { label="Klassen Farben", tooltip="Erlaubt dir festzulegen, ob die Namen nach Klassenfarbe eingefärbt werden sollen oder welche Farbe für jede Klasse verwendet werden soll." }
obj["inputOkay"]				= { label=OKAY, tooltip="Eingaben übernehmen."}
obj["inputCancel"]				= { label=CANCEL, tooltip="Eingaben zurücksetzen."}
obj["genericSave"]				= { label=SAVE, tooltip="Speichert die Änderungen."}
obj["genericCancel"]			= { label=CANCEL, tooltip="Setzt die Änderungen zurück."}
obj["addScrollArea"]			= { label="Neuer Scroll-Bereich", tooltip="Einen neuen Scroll-Bereich auswählen, dem Ereignisse und Auslöser zugewiesen werden können."}
obj["configScrollAreas"]		= { label="Scroll-Bereiche konfigurieren", tooltip="Konfiguriert die normalen und Sticky-Styles, Text-Ausrichtung, Scroll Weite/Höhe und Position der Scroll-Bereiche."}
obj["editScrollAreaName"]		= { tooltip="Klicken, um den Namen des Scroll-Bereichs zu bearbeiten."}
obj["scrollAreaFontSettings"]	= { tooltip="Klicken, um die Schrifteinstellungen des Scroll-Bereichs zu bearbeiten, welche von allen Ereignissen dieses Bereichs übernommen werden, sofern sie nicht überschrieben werden."}
obj["deleteScrollArea"]			= { tooltip="Klicken, um den Scroll-Bereich zu löschen."}
obj["scrollAreasPreview"]		= { label="Vorschau", tooltip="Eine Vorschau auf die Änderungen."}
obj["toggleAll"]				= { label="Alle umschalten", tooltip="Die Aktivierung aller Ereignisse in der ausgewählten Kategorie umschalten."}
obj["moveAll"]					= { label="Alle verschieben", tooltip="Verschiebt alle Ereignisse in der ausgewählten Kategorie zu dem ausgewählten Scroll-Bereich."}
obj["eventFontSettings"]		= { tooltip="Klicken, um die Schrifteinstellungen für dieses Ereignis zu bearbeiten."}
obj["eventSettings"]			= { tooltip="Klicken, um die Ereigniseinstellungen wie Scroll-Bereich, Text, Sound, etc. zu bearbeiten."}
obj["itemsAllowed"]				= { label="Gegenstände erlauben", tooltip="Festgelegte Gegenstände unabhängig der Gegenstandsqualität immer anzeigen."}
obj["itemExclusions"]			= { label="Gegenstände ignorieren", tooltip="Verhindert, dass festgelegte Gegenstände angezeigt werden."}
obj["addItem"]					= { label="Gegenstand hinzufügen", tooltip="Neuen Gegenstand zur Liste hinzufügen."}
obj["deleteItem"]				= { tooltip="Klicken, um Gegenstand zu entfernen."}



obj = L.EDITBOXES
obj["copyProfile"]		= { label="Neuer Profilname:", tooltip="Der Name des neuen Profils auf den das eben gewählte Profil kopiert werden soll."}
obj["partialEffect"]	= { tooltip="Der Trailer, der angehängt wird wenn der Partielle Effekte erscheint."}
obj["scrollAreaName"]	= { label="Neuen Scroll-Bereich-Namen eingeben:", tooltip="Neuer Name für den Scroll-Bereich."}
obj["xOffset"]			= { label="X-Achse:", tooltip="Die X-Achse des ausgewählten Scroll-Bereichs."}
obj["yOffset"]			= { label="Y-Achse:", tooltip="Die Y-Achse des ausgewählten Scroll-Bereichs."}
obj["eventMessage"]		= { label="Ausgabenachricht eingeben:", tooltip="Die Nachricht die angezeigt wird, wenn das Ereignis auftritt."}
obj["iconSkill"]		= { label="Fähigkeitssymbol:", tooltip="Der Name oder Spell-ID des Zaubers mit dem Symbol das angezeigt wird, wenn das Ereignis auftritt.\n\nMSBT wird versuchen, automatisch ein Symbol auszuwählen, wenn keines festgelegt wurde.\n\nNOTIZ: Eine Spell-ID muss anstatt einem Namen benutzt werden, wenn die Fähigkeit nicht im Zauberbuch für die Klasse, die gespielt wird, während das Ereignis auftritt, ist. Die meisten Datenbanken wie z.B. Wowhead Dir dabei helfen."}
obj["itemName"]			= { label="Gegenstandsname:", tooltip="Name des Gegenstandes, der hinzugefügt werden soll."}


obj = L.SLIDERS
obj["animationSpeed"]		= { label="Animationsgeschwindigkeit", tooltip="Die Master-Geschwindigkeit der Animation."}
obj["normalFontSize"]		= { label="Normale Schriftgröße", tooltip="Die Schriftgröße für nicht-kritische Treffer."}
obj["normalFontOpacity"]	= { label="Normale Transparenz", tooltip="Die Schrifttransparenz für nicht-kritische Treffer."}
obj["critFontSize"]			= { label="Kritische Schriftgröße", tooltip="Die Schriftgröße für kritische Treffer."}
obj["critFontOpacity"]		= { label="Kritische Transparenz", tooltip="Die Schrifttransparenz für kritische Treffer."}
obj["scrollHeight"]			= { label="Scroll-Höhe", tooltip="Die Höhe des Scroll-Bereichs."}
obj["scrollWidth"]			= { label="Scroll-Weite", tooltip="Die Weite des Scroll-Bereichs."}
obj["scrollAnimationSpeed"]	= { label="Geschwindigkeit", tooltip="Die Geschwindigkeit der Animation des Scroll-Bereichs."}
obj["powerThreshold"]		= { label="Energiesschwelle", tooltip="Die Schwelle, die die Energie überschreiten muss, um angezeigt zu werden."}
obj["healThreshold"]		= { label="Heilungsschwelle", tooltip="Die Schwelle, die die Heilung überschreiten muss, um angezeigt zu werden."}
obj["damageThreshold"]		= { label="Schadensschwelle", tooltip="Die Schwelle, die der Schaden überschreiten muss, um angezeigt zu werden."}
obj["dotThrottleTime"]		= { label="DoTs drosseln", tooltip="Die Nummer in Sekunden, die DoTs gedrosselt werden sollen."}
obj["hotThrottleTime"]		= { label="HoTs drosseln", tooltip="Die Nummer in Sekunden, die HoTs gedrosselt werden sollen."}
obj["powerThrottleTime"]	= { label="Energie drosseln", tooltip="Die Nummer in Sekunden, die Energieänderungen gedrosselt werden sollen."}


obj = L.EVENT_CATEGORIES
obj[1] = "Eingehend Spieler"
obj[2] = "Eingehend Begleiter"
obj[3] = "Ausgehend Spieler"
obj[4] = "Ausgehend Begleiter"
obj[5] = "Benachrichtigung"



obj = L.EVENT_CODES
obj["DAMAGE_TAKEN"]			= "%a - Menge des erhaltenen Schadens.\n"
obj["HEALING_TAKEN"]		= "%a - Menge der erhaltenen Heilung.\n"
obj["DAMAGE_DONE"]			= "%a - Menge des Schadens.\n"
obj["HEALING_DONE"]			= "%a - Geheilte Menge.\n"
obj["ABSORBED_AMOUNT"]		= "%a - Menge des absobierten Schadens.\n"
obj["AURA_AMOUNT"]			= "%a - Menge der Stapel für eine Aura.\n"
obj["ENERGY_AMOUNT"]		= "%a - Menge der Energie.\n"
obj["CP_AMOUNT"]			= "%a - Menge der momentanen Combo-Punkte.\n"
obj["HOLY_POWER_AMOUNT"]	= "%a - Menge der heiligen Kraft.\n"
obj["HONOR_AMOUNT"]			= "%a - Menge der Ehre.\n"
obj["REP_AMOUNT"]			= "%a - Menge des Rufs.\n"
obj["ITEM_AMOUNT"]			= "%a - Menge des geplünderten Gegenstands.\n"
obj["SKILL_AMOUNT"]			= "%a - Menge der Punkte, die du in der Fähigkeit hast.\n"
obj["EXPERIENCE_AMOUNT"]	= "%a - Menge der erhaltenen Erfahrung.\n"
obj["PARTIAL_AMOUNT"]		= "%a - Menge des partiellen Effekts.\n"
obj["ATTACKER_NAME"]		= "%n - Name des Angreifers.\n"
obj["HEALER_NAME"]			= "%n - Name des Heilers.\n"
obj["ATTACKED_NAME"]		= "%n - Name der angegriffenen Einheit.\n"
obj["HEALED_NAME"]			= "%n - Name der geheilten Einheit.\n"
obj["BUFFED_NAME"]			= "%n - Name der gebufften Einheit.\n"
obj["UNIT_KILLED"]			= "%n - Name der getöteten Einheit.\n"
obj["SKILL_NAME"]			= "%s - Name der Fähigkeit.\n"
obj["SPELL_NAME"]			= "%s - Name des Zaubers.\n"
obj["DEBUFF_NAME"]			= "%s - Name des Debuffs.\n"
obj["BUFF_NAME"]			= "%s - Name des Buffs\n"
obj["ITEM_BUFF_NAME"]		= "%s - Name des Gegenstands-Buffs.\n"
obj["EXTRA_ATTACKS"]		= "%s - Name der Fähigkeit, die Extraangriffe gewährt.\n"
obj["SKILL_LONG"]			= "%sl - Lange Form von %s. Wird benutzt, um Abkürzungen für das Ereignis zu überschreiben.\n"
obj["DAMAGE_TYPE_TAKEN"]	= "%t - Art des erhaltenen Schadens.\n"
obj["DAMAGE_TYPE_DONE"]		= "%t - Art des angerichteten Schadens.\n"
obj["ENVIRONMENTAL_DAMAGE"]	= "%e - Name der Schadensquelle (Fallen, Ertrinken, Lava, usw.).\n"
obj["FACTION_NAME"]			= "%e - Name der Fraktion.\n"
obj["EMOTE_TEXT"]			= "%e - Der Text der Geste.\n"
obj["MONEY_TEXT"]			= "%e - Der Text des erhaltenen Geldes.\n"
obj["ITEM_NAME"]			= "%e - Der Name des geplünderten Gegenstands.\n"
obj["POWER_TYPE"]			= "%p - Art der Energie (Energie, Wut, Mana, Runenmacht, usw.).\n"
obj["TOTAL_ITEMS"]			= "%t - Gesamte Anzahl der geplünderten Gegenstände im Inventar."



obj = L.INCOMING_PLAYER_EVENTS
obj["INCOMING_DAMAGE"]						= { label="Melee: Treffer", tooltip="Aktiviert eingehende Melee-Treffer."}
obj["INCOMING_DAMAGE_CRIT"]					= { label="Melee: Krit", tooltip="Aktiviert eingehende Melee-Krits."}
obj["INCOMING_MISS"]						= { label="Melee: Fehlschlag", tooltip="Aktiviert eingehende Melee-Fehlschläge."}
obj["INCOMING_DODGE"]						= { label="Melee: Ausweichen", tooltip="Aktiviert eingehendes Melee-Ausweichen."}
obj["INCOMING_PARRY"]						= { label="Melee: Parieren", tooltip="Aktiviert eingehendes Melee-Parieren."}
obj["INCOMING_BLOCK"]						= { label="Melee: Blocken", tooltip="Aktiviert eingehendes Melee-Blocken."}
obj["INCOMING_DEFLECT"]						= { label="Melee: Abwehr", tooltip="Aktiviert eingehende Melee-Abwehr."}
obj["INCOMING_ABSORB"]						= { label="Melee: Absorbieren", tooltip="Aktiviert eingehenden, absorbierten Meleeschaden."}
obj["INCOMING_IMMUNE"]						= { label="Melee: Immunität", tooltip="Aktiviert eingehenden Meleeschaden, gegen den du immun bist."}
obj["INCOMING_SPELL_DAMAGE"]				= { label="Fähigkeit: Treffer", tooltip="Aktiviert eingehende Fähigkeitstreffer."}
obj["INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Fähigkeit: Krit", tooltip="Aktiviert eingehende Fähigkeitskrits."}
obj["INCOMING_SPELL_DOT"]					= { label="Fähigkeit: DoT", tooltip="Aktiviert eingehenden Fähigkeitsschaden über Zeit."}
obj["INCOMING_SPELL_DOT_CRIT"]				= { label="Fähigkeit: DoT-Krit", tooltip="Aktiviert eingehenden, kritischen Fähigkeitsschaden über Zeit."}
obj["INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Schadensschild: Treffer", tooltip="Aktiviert eingehenden Schaden durch Schadensschilde."}
obj["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Schadensschild: Krit", tooltip="Aktiviert eingehenden, kritischen Schaden durch Schadensschilde."}
obj["INCOMING_SPELL_MISS"]					= { label="Fähigkeit: Fehlschlag", tooltip="Aktiviert eingehende Fähigkeits-Fehlschläge."}
obj["INCOMING_SPELL_DODGE"]					= { label="Fähigkeit: Ausweichen", tooltip="Aktiviert eingehendes Fähigkeits-Ausweichen."}
obj["INCOMING_SPELL_PARRY"]					= { label="Fähigkeit: Parieren", tooltip="Aktiviert eingehendes Fähigkeits-Parieren."}
obj["INCOMING_SPELL_BLOCK"]					= { label="Fähigkeit: Blocken", tooltip="Aktiviert eingehendes Fähigkeits-Blocken."}
obj["INCOMING_SPELL_DEFLECT"]				= { label="Fähigkeit: Abwehr", tooltip="Aktiviert eingehende Fähigkeits-Abwehr."}
obj["INCOMING_SPELL_RESIST"]				= { label="Fähigkeit: Widerstehen", tooltip="Aktiviert eingehendes Widerstehen von Fähigkeiten."}
obj["INCOMING_SPELL_ABSORB"]				= { label="Fähigkeit: Absorbieren", tooltip="Aktiviert eingehenden, absorbierten Fähigkeitsschaden."}
obj["INCOMING_SPELL_IMMUNE"]				= { label="Fähigkeit: Immunität", tooltip="Aktiviert eingehenden Fähigkeitsschaden, gegen den du immun bist."}
obj["INCOMING_SPELL_REFLECT"]				= { label="Fähigkeit: Reflektieren", tooltip="Aktiviert eingehende Reflektionen von Fähigkeitsschaden."}
obj["INCOMING_SPELL_INTERRUPT"]				= { label="Fähigkeit: Unterbrechen", tooltip="Aktiviert eingehende Fähigkeitsunterbrechungen."}
obj["INCOMING_HEAL"]						= { label="Heilung", tooltip="Aktiviert eingehende Heilungen."}
obj["INCOMING_HEAL_CRIT"]					= { label="Heilung: Krit", tooltip="Aktiviert eingehende, kritische Heilungen."}
obj["INCOMING_HOT"]							= { label="HoT", tooltip="Aktiviert eingehende Heilungen über Zeit."}
obj["INCOMING_HOT_CRIT"]					= { label="HoT: Krit", tooltip="Aktiviert eingehende, kritische Heilungen über Zeit."}
obj["INCOMING_ENVIRONMENTAL"]				= { label="Umwelt-Schaden", tooltip="Aktiviert Umwelt-Schaden (Fallen, Ertrinken, Lava, usw.)."}

obj = L.INCOMING_PET_EVENTS
obj["PET_INCOMING_DAMAGE"]						= { label="Melee: Treffer", tooltip="Aktiviert für Begleiter eingehende Melee-Treffer."}
obj["PET_INCOMING_DAMAGE_CRIT"]					= { label="Melee: Krit", tooltip="Aktiviert für Begleiter eingehende Melee-Krits."}
obj["PET_INCOMING_MISS"]						= { label="Melee: Fehlschlag", tooltip="Aktiviert für Begleiter eingehende Melee-Fehlschläge."}
obj["PET_INCOMING_DODGE"]						= { label="Melee: Ausweichen", tooltip="Aktiviert für Begleiter eingehendes Melee-Ausweichen."}
obj["PET_INCOMING_PARRY"]						= { label="Melee: Parieren", tooltip="Aktiviert für Begleiter eingehendes Melee-Parieren."}
obj["PET_INCOMING_BLOCK"]						= { label="Melee: Blocken", tooltip="Aktiviert für Begleiter eingehendes Melee-Blocken."}
obj["PET_INCOMING_DEFLECT"]						= { label="Melee: Abwehr", tooltip="Aktiviert für Begleiter eingehende Melee-Abwehr."}
obj["PET_INCOMING_ABSORB"]						= { label="Melee: Absorbieren", tooltip="Aktiviert für Begleiter eingehenden, absorbierten Meleeschaden."}
obj["PET_INCOMING_IMMUNE"]						= { label="Melee: Immunität", tooltip="Aktiviert eingehenden Meleeschaden, gegen den dein Begleiter immun ist."}
obj["PET_INCOMING_SPELL_DAMAGE"]				= { label="Fähigkeit: Treffer", tooltip="Aktiviert für Begleiter eingehende Fähigkeitstreffer."}
obj["PET_INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Fähigkeit: Krit", tooltip="Aktiviert für Begleiter eingehende Fähigkeitskrits."}
obj["PET_INCOMING_SPELL_DOT"]					= { label="Fähigkeit: DoT", tooltip="Aktiviert für Begleiter eingehenden Fähigkeitsschaden über Zeit."}
obj["PET_INCOMING_SPELL_DOT_CRIT"]				= { label="Fähigkeit: DoT-Krit", tooltip="Aktiviert für Begleiter eingehenden, kritischen Fähigkeitsschaden über Zeit."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Schadensschild: Treffer", tooltip="Aktiviert für Begleiter eingehenden Schaden durch Schadensschilde."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Schadensschild: Krit", tooltip="Aktiviert für Begleiter eingehenden, kritischen Schaden durch Schadensschilde."}
obj["PET_INCOMING_SPELL_MISS"]					= { label="Fähigkeit: Fehlschlag", tooltip="Aktiviert für Begleiter eingehende Fähigkeits-Fehlschläge."}
obj["PET_INCOMING_SPELL_DODGE"]					= { label="Fähigkeit: Ausweichen", tooltip="Aktiviert für Begleiter eingehendes Fähigkeits-Ausweichen."}
obj["PET_INCOMING_SPELL_PARRY"]					= { label="Fähigkeit: Parieren", tooltip="Aktiviert für Begleiter eingehendes Fähigkeits-Parieren."}
obj["PET_INCOMING_SPELL_BLOCK"]					= { label="Fähigkeit: Blocken", tooltip="Aktiviert für Begleiter eingehendes Fähigkeits-Blocken."}
obj["PET_INCOMING_SPELL_DEFLECT"]				= { label="Fähigkeit: Abwehr", tooltip="Aktiviert für Begleiter eingehende Fähigkeits-Abwehr."}
obj["PET_INCOMING_SPELL_RESIST"]				= { label="Fähigkeit: Widerstehen", tooltip="Aktiviert für Begleiter eingehendes Widerstehen von Fähigkeiten."}
obj["PET_INCOMING_SPELL_ABSORB"]				= { label="Fähigkeit: Absorbieren", tooltip="Aktiviert für Begleiter eingehenden, absorbierten Fähigkeitsschaden."}
obj["PET_INCOMING_SPELL_IMMUNE"]				= { label="Fähigkeit: Immunität", tooltip="Aktiviert eingehenden Fähigkeitsschaden, gegen den dein Begleiter immun ist."}
obj["PET_INCOMING_HEAL"]						= { label="Heilung", tooltip="Aktiviert für Begleiter eingehende Heilungen."}
obj["PET_INCOMING_HEAL_CRIT"]					= { label="Heilung: Krit", tooltip="Aktiviert für Begleiter eingehende, kritische Heilungen."}
obj["PET_INCOMING_HOT"]							= { label="HoT", tooltip="Aktiviert für Begleiter eingehende Heilungen über Zeit."}
obj["PET_INCOMING_HOT_CRIT"]					= { label="HoT: Krit", tooltip="Aktiviert für Begleiter eingehende, kritische Heilungen über Zeit."}



obj = L.OUTGOING_PLAYER_EVENTS
obj["OUTGOING_DAMAGE"]						= { label="Melee: Treffer", tooltip="Aktiviert ausgehende Melee-Treffer."}
obj["OUTGOING_DAMAGE_CRIT"]					= { label="Melee: Krit", tooltip="Aktiviert ausgehende Melee-Krits."}
obj["OUTGOING_MISS"]						= { label="Melee: Fehlschlag", tooltip="Aktiviert ausgehende Melee-Fehlschläge."}
obj["OUTGOING_DODGE"]						= { label="Melee: Ausweichen", tooltip="Aktiviert ausgehendes Melee-Ausweichen."}
obj["OUTGOING_PARRY"]						= { label="Melee: Parieren", tooltip="Aktiviert ausgehendess Melee-Parieren."}
obj["OUTGOING_BLOCK"]						= { label="Melee: Blocken", tooltip="Aktiviert ausgehendes Melee-Blocken."}
obj["OUTGOING_DEFLECT"]						= { label="Melee: Abwehr", tooltip="Aktiviert ausgehende Melee-Abwehr."}
obj["OUTGOING_ABSORB"]						= { label="Melee: Absorbieren", tooltip="Aktiviert ausgehenden, absorbierten Meleeschaden."}
obj["OUTGOING_IMMUNE"]						= { label="Melee: Immunität", tooltip="Aktiviert ausgehenden Meleeschaden, gegen den der Feind immun ist."}
obj["OUTGOING_EVADE"]						= { label="Melee: Entkommen", tooltip="Aktiviert ausgehendes Melee-Entkommen."}
obj["OUTGOING_SPELL_DAMAGE"]				= { label="Fähigkeit: Treffer", tooltip="Aktiviert ausgehende Fähigkeitstreffer."}
obj["OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Fähigkeit: Krit", tooltip="Aktiviert ausgehende Fähigkeitskrits."}
obj["OUTGOING_SPELL_DOT"]					= { label="Fähigkeit: DoT", tooltip="Aktiviert ausgehenden Fähigkeitsschaden über Zeit."}
obj["OUTGOING_SPELL_DOT_CRIT"]				= { label="Fähigkeit: DoT-Krit", tooltip="Aktiviert ausgehenden, kritischen Fähigkeitsschaden über Zeit."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Schadensschild: Treffer", tooltip="Aktiviert ausgehenden Schaden durch Schadensschilde."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Schadensschild: Krit", tooltip="Aktiviert ausgehenden, kritischen Schaden durch Schadensschilde."}
obj["OUTGOING_SPELL_MISS"]					= { label="Fähigkeit: Fehlschlag", tooltip="Aktiviert ausgehende Fähigkeits-Fehlschläge."}
obj["OUTGOING_SPELL_DODGE"]					= { label="Fähigkeit: Ausweichen", tooltip="Aktiviert ausgehendes Fähigkeits-Ausweichen."}
obj["OUTGOING_SPELL_PARRY"]					= { label="Fähigkeit: Parieren", tooltip="Aktiviert ausgehendes Fähigkeits-Parieren."}
obj["OUTGOING_SPELL_BLOCK"]					= { label="Fähigkeit: Blocken", tooltip="Aktiviert ausgehendes Fähigkeits-Blocken."}
obj["OUTGOING_SPELL_DEFLECT"]				= { label="Fähigkeit: Abwehr", tooltip="Aktiviert ausgehende Fähigkeits-Abwehr."}
obj["OUTGOING_SPELL_RESIST"]				= { label="Fähigkeit: Widerstehen", tooltip="Aktiviert ausgehendes Widerstehen von Fähigkeiten."}
obj["OUTGOING_SPELL_ABSORB"]				= { label="Fähigkeit: Absorbieren", tooltip="Aktiviert ausgehenden, absorbierten Fähigkeitsschaden."}
obj["OUTGOING_SPELL_IMMUNE"]				= { label="Fähigkeit: Immunität", tooltip="Aktiviert ausgehenden Fähigkeitsschaden, gegen den der Feind immun ist."}
obj["OUTGOING_SPELL_REFLECT"]				= { label="Fähigkeit: Reflektieren", tooltip="Aktiviert Reflektionen von Fähigkeitsschaden, der zu dir zurückgeworfen wird."}
obj["OUTGOING_SPELL_INTERRUPT"]				= { label="Fähigkeit: Unterbrechen", tooltip="Aktiviert ausgehende Fähigkeitsunterbrechungen."}
obj["OUTGOING_SPELL_EVADE"]					= { label="Fähigkeit: Entkommen", tooltip="Aktiviert ausgehendes Fähigkeits-Entkommen."}
obj["OUTGOING_HEAL"]						= { label="Heilung", tooltip="Aktiviert ausgehende Heilungen."}
obj["OUTGOING_HEAL_CRIT"]					= { label="Heilung: Krit", tooltip="Aktiviert ausgehende, kritische Heilungen."}
obj["OUTGOING_HOT"]							= { label="HoT", tooltip="Aktiviert ausgehende Heilungen über Zeit."}
obj["OUTGOING_HOT_CRIT"]					= { label="HoT: Krit", tooltip="Aktiviert ausgehende, kritische Heilungen über Zeit."}
obj["OUTGOING_DISPEL"]						= { label="Dispel", tooltip="Aktiviert ausgehende Entzauberungen."}

obj = L.OUTGOING_PET_EVENTS
obj["PET_OUTGOING_DAMAGE"]						= { label="Melee: Treffer", tooltip="Aktiviert von Begleiter ausgehende Melee-Treffer."}
obj["PET_OUTGOING_DAMAGE_CRIT"]					= { label="Melee: Krit", tooltip="Aktiviert von Begleiter ausgehende Melee-Krits."}
obj["PET_OUTGOING_MISS"]						= { label="Melee: Fehlschlag", tooltip="Aktiviert von Begleiter ausgehende Melee-Fehlschläge."}
obj["PET_OUTGOING_DODGE"]						= { label="Melee: Ausweichen", tooltip="Aktiviert von Begleiter ausgehendes Melee-Ausweichen."}
obj["PET_OUTGOING_PARRY"]						= { label="Melee: Parieren", tooltip="Aktiviert von Begleiter ausgehendes Melee-Parieren."}
obj["PET_OUTGOING_BLOCK"]						= { label="Melee: Blocken", tooltip="Aktiviert von Begleiter ausgehendes Melee-Blocken."}
obj["PET_OUTGOING_DEFLECT"]						= { label="Melee: Abwehr", tooltip="Aktiviert von Begleiter ausgehende Melee-Abwehr."}
obj["PET_OUTGOING_ABSORB"]						= { label="Melee: Absorbieren", tooltip="Aktiviert von Begleiter ausgehenden, absorbierten Meleeschaden."}
obj["PET_OUTGOING_IMMUNE"]						= { label="Melee: Immunität", tooltip="Aktiviert von Begleiter ausgehenden Meleeschaden, gegen den der Feind immun ist."}
obj["PET_OUTGOING_EVADE"]						= { label="Melee: Entkommen", tooltip="Aktiviert von Begleiter ausgehendes Melee-Entkommen."}
obj["PET_OUTGOING_SPELL_DAMAGE"]				= { label="Fähigkeit: Treffer", tooltip="Aktiviert von Begleiter ausgehende Fähigkeitstreffer."}
obj["PET_OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Fähigkeit: Krit", tooltip="Aktiviert von Begleiter ausgehende Fähigkeitskrits."}
obj["PET_OUTGOING_SPELL_DOT"]					= { label="Fähigkeit: DoT", tooltip="Aktiviert von Begleiter ausgehenden Fähigkeitsschaden über Zeit."}
obj["PET_OUTGOING_SPELL_DOT_CRIT"]				= { label="Fähigkeit: DoT Kritisch", tooltip="Aktiviert von Begleiter ausgehenden, kritischen Fähigkeitsschaden über Zeit."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Schadensschild: Treffer", tooltip="Aktiviert ausgehenden Schaden durch Schadensschilde des Begleiters."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Schadensschild: Krit", tooltip="Aktiviert ausgehenden, kritischen Schaden durch Schadensschilde des Begleiters."}
obj["PET_OUTGOING_SPELL_MISS"]					= { label="Fähigkeit: Fehlschlag", tooltip="Aktiviert von Begleiter ausgehende Fähigkeits-Fehlschläge."}
obj["PET_OUTGOING_SPELL_DODGE"]					= { label="Fähigkeit: Ausweichen", tooltip="Aktiviert von Begleiter ausgehendes Fähigkeits-Ausweichen."}
obj["PET_OUTGOING_SPELL_PARRY"]					= { label="Fähigkeit: Parieren", tooltip="Aktiviert von Begleiter ausgehendes Fähigkeits-Parieren."}
obj["PET_OUTGOING_SPELL_BLOCK"]					= { label="Fähigkeit: Blocken", tooltip="Aktiviert von Begleiter ausgehendes Fähigkeits-Blocken."}
obj["PET_OUTGOING_SPELL_DEFLECT"]				= { label="Fähigkeit: Abwehr", tooltip="Aktiviert von Begleiter ausgehende Fähigkeits-Abwehr."}
obj["PET_OUTGOING_SPELL_RESIST"]				= { label="Fähigkeit: Widerstehen", tooltip="Aktiviert von Begleiter ausgehendes Widerstehen von Fähigkeiten."}
obj["PET_OUTGOING_SPELL_ABSORB"]				= { label="Fähigkeit: Absorbieren", tooltip="Aktiviert von Begleiter ausgehenden, absorbierten Fähigkeitsschaden."}
obj["PET_OUTGOING_SPELL_IMMUNE"]				= { label="Fähigkeit: Immunität", tooltip="Aktiviert von Begleiter ausgehenden Fähigkeitsschaden, gegen den der Feind immun ist."}
obj["PET_OUTGOING_SPELL_EVADE"]					= { label="Fähigkeit: Unterbrechen", tooltip="Aktiviert von Begleiter ausgehende Fähigkeitsunterbrechungen."}
obj["PET_OUTGOING_HEAL"]						= { label="Heilung", tooltip="Aktiviert von Begleiter ausgehende Heilungen."}
obj["PET_OUTGOING_HEAL_CRIT"]					= { label="Heilung: Krit", tooltip="Aktiviert von Begleiter ausgehende, kritische Heilungen."}
obj["PET_OUTGOING_HOT"]							= { label="HoT", tooltip="Aktiviert von Begleiter ausgehende Heilungen über Zeit."}
obj["PET_OUTGOING_HOT_CRIT"]					= { label="HoT: Krit", tooltip="Aktiviert von Begleiter ausgehende, kritische Heilungen über Zeit."}
obj["PET_OUTGOING_DISPEL"]						= { label="Dispel", tooltip="Aktiviert von Begleiter ausgehende Entzauberungen."}



obj = L.NOTIFICATION_EVENTS
obj["NOTIFICATION_DEBUFF"]				= { label="Debuffs", tooltip="Aktiviert Debuffs, wenn du betroffen bist."}
obj["NOTIFICATION_DEBUFF_STACK"]		= { label="Debuff-Stapel", tooltip="Aktiviert Debuff-Stapel, wenn du betroffen bist."}
obj["NOTIFICATION_BUFF"]				= { label="Buffs", tooltip="Aktiviert Buffs, die du erhälst."}
obj["NOTIFICATION_BUFF_STACK"]			= { label="Buff-Stacks", tooltip="Aktiviert Buff-Stapel, die du erhälst."}
obj["NOTIFICATION_ITEM_BUFF"]			= { label="Gegenstands-Buffs", tooltip="Aktiviert Buffs, die ein Gegenstand erhält."}
obj["NOTIFICATION_DEBUFF_FADE"]			= { label="Debuff verblasst", tooltip="Aktiviert Debuffs, die von dir verblassen."}
obj["NOTIFICATION_BUFF_FADE"]			= { label="Buff verblasst", tooltip="Aktiviert Buffs, die von dir verblassen."}
obj["NOTIFICATION_ITEM_BUFF_FADE"]		= { label="Gegenstands-Buff verblasst", tooltip="Aktiviert Gegenstands-Buffs, die von dir verblassen."}
obj["NOTIFICATION_COMBAT_ENTER"]		= { label="Kampfeintritt", tooltip="Aktiviert, wenn du in den Kampf eintrittst."}
obj["NOTIFICATION_COMBAT_LEAVE"]		= { label="Kampfaustritt", tooltip="Aktiviert, wenn du in den Kampf verlässt."}
obj["NOTIFICATION_POWER_GAIN"]			= { label="Energie erhalten", tooltip="Aktiviert, wenn du zusätzliches Mana, Wut oder Energie erhälst."}
obj["NOTIFICATION_POWER_LOSS"]			= { label="Energie verloren", tooltip="Aktiviert, wenn du durch Abzug Mana, Wut oder Energie verlierst."}
obj["NOTIFICATION_CP_GAIN"]				= { label="Combo-Punkte erhalten", tooltip="Aktiviert, wenn du Combo-Punkte bekommst."}
obj["NOTIFICATION_CP_FULL"]				= { label="Combo-Punkte komplett", tooltip="Aktiviert, wenn du alle Combo-Punkte erreicht hast."}
obj["NOTIFICATION_HOLY_POWER_CHANGE"]	= { label="Heilige Kraft verändert", tooltip="Aktiviert, wenn sich deine Heilige Kraft verändert."}
obj["NOTIFICATION_HOLY_POWER_FULL"]		= { label="Heilige Kraft komplett", tooltip="Aktiviert, wenn deine Heilige Kraft voll ist."}
obj["NOTIFICATION_HONOR_GAIN"]			= { label="Ehre erhalten", tooltip="Aktiviert, wenn du Ehre erhälst."}
obj["NOTIFICATION_REP_GAIN"]			= { label="Ruf erhalten", tooltip="Aktiviert, wenn du Ruf erhälst."}
obj["NOTIFICATION_REP_LOSS"]			= { label="Ruf verloren", tooltip="Aktiviert, wenn du Ruf verlierst."}
obj["NOTIFICATION_SKILL_GAIN"]			= { label="Skillpunkt erhalten", tooltip="Aktiviert, wenn du einen Skillpunkt erhälst."}
obj["NOTIFICATION_EXPERIENCE_GAIN"]		= { label="Erfahrung erhalten", tooltip="Aktiviert, wenn du Erfahrung erhälst."}
obj["NOTIFICATION_PC_KILLING_BLOW"]		= { label="Todesstoß Spieler", tooltip="Aktiviert, wenn du einen Todesstoß bei einem Spieler anbringst."}
obj["NOTIFICATION_NPC_KILLING_BLOW"]	= { label="Todesstoß NPC", tooltip="Aktiviert, wenn du einen Todesstoß bei einem NPC anbringst."}
obj["NOTIFICATION_EXTRA_ATTACK"]		= { label="Extraattacken", tooltip="Aktiviert, wenn du Extraattacken durch Windzorn, Schwertspezialisierung usw. erhälst."}
obj["NOTIFICATION_ENEMY_BUFF"]			= { label="Feind erhält Buff", tooltip="Aktiviert, wenn dein aktuelles, feindliches Ziel einen Buff erhält."}
obj["NOTIFICATION_MONSTER_EMOTE"]		= { label="Monster Emotes", tooltip="Aktiviert Emotes, die dein aktuelles Ziel sagt."}



obj = L.OUTLINES
obj[1] = "Kein"
obj[2] = "Dünn"
obj[3] = "Dick"
obj[4] = "Monochrom"
obj[5] = "Monochrom + Dünn"
obj[6] = "Monochrom + Dick"

obj = L.TEXT_ALIGNS
obj[1] = "Links"
obj[2] = "Zentriert"
obj[3] = "Rechts"





obj = L.ANIMATION_STYLE_DATA
obj["Angled"]		= "Gewinkelt"
obj["Horizontal"]	= "Horizontale"
obj["Parabola"]		= "Parabel"
obj["Straight"]		= "Gerade"
obj["Static"]		= "Statisch"
obj["Pow"]			= "Pow"

obj["Alternate"]	= "Alternativ"
obj["Left"]			= "Links"
obj["Right"]		= "Rechts"
obj["Up"]			= "Aufwärts"
obj["Down"]			= "Abwärts"

obj["AngleUp"]		= "Winkel aufwärts"
obj["AngleDown"]	= "Winkel abwärts"
obj["GrowUp"]		= "Wachsen aufwärts"
obj["GrowDown"]		= "Wachsen abwärts"
obj["CurvedLeft"]	= "Gerundet Links"
obj["CurvedRight"]	= "Gerundet Rechts"
obj["Jiggle"]		= "Rütteln"
obj["Normal"]		= "Normal"

L.MSG_INVALID_CUSTOM_SOUND_NAME		= "Ungültiger Sound-Name."
L.MSG_SOUND_NAME_ALREADY_EXISTS		= "Sound-Name existiert bereits."
L.MSG_INVALID_SOUND_FILE			= "Sound muss eine .ogg Datei sein."
L.CHECKBOXES["enableSounds"]				= { label="Sounds aktivieren", tooltip="Sounds abspielen, die Ereignissen und Auslösern zugewiesen wurden."}
L.DROPDOWNS["sound"]				= { label="Sound:", tooltip="Wählt den Sound aus, der abgespielt werden soll, wenn das Ereignis erscheint."}
L.BUTTONS["addCustomSound"]			= { label="Sound hinzufügen", tooltip="Fügt einen benutzerdefinierten Sound zu der Liste der verfügbaren Sounds.\n\nWARNUNG: Die Datei muss in dem Ziel-Verzeichnis existieren, *BEVOR* WoW gestartet wurde.\n\nEs wird empfohlen, die Datei in den MikScrollingBattleText\\Sounds Ordner zu kopieren um Fehler zu vermeiden."}
L.BUTTONS["customSound"]				= { tooltip="Klicken, um eine benutzerdefinierte Sound-Datei auszuwählen." }
L.BUTTONS["playSound"]				= { label="Abspielen", tooltip="Klicken, um den ausgewählten Sound abzuspielen."}
L.EDITBOXES["customSoundName"]	= { label="Sound Name:", tooltip="Der Name wird benutzt um den Sound zu identifizieren.\n\nBeispiel: Mein Sound"}
L.EDITBOXES["customSoundPath"]	= { label="Sound Pfad:", tooltip="Der Pfad zu der Sound Datei.\n\nNOTIZ: Wenn die Datei in dem empfohlenen MikScrollingBattleText\\Sounds Ordner ist, muss nur der Dateiname hier eingegeben werden anstatt der ganze Pfad.\n\nBeispiel: mySound.ogg "}
L.EDITBOXES["soundFile"]		= { label="Sound-Dateiname:", tooltip="Der Name der Sound Datei zum Abspielen wenn das Ereignis erscheint."}

L.MSG_NEW_TRIGGER = "Neuer Auslöser"
L.MSG_TRIGGER_CLASSES = "Klassen Auslöser"
L.MSG_MAIN_EVENTS = "Hauptereignisse"
L.MSG_TRIGGER_EXCEPTIONS = "Auslöser ausschließen"
L.MSG_EVENT_CONDITIONS = "Ereignisbedingungen"
L.MSG_SKILLS = "Fähigkeiten"
L.MSG_SKILL_ALREADY_EXISTS = "Fähigkeitsname existiert bereits."
L.MSG_INVALID_SKILL_NAME = "Ungültiger Fähigkeitsname."
L.MSG_CONDITION = "Bedingung"
L.MSG_CONDITIONS = "Bedingungen"
L.CHECKBOXES["allClasses"] = { label="Alle Klassen"}
L.DROPDOWNS["mainEvent"] = { label="Hauptereignis:"}
L.DROPDOWNS["triggerCondition"] = { label="Bedingung:", tooltip="Die Bedingung, die getestet wird."}
L.DROPDOWNS["triggerRelation"] = { label="Relation:"}
L.DROPDOWNS["triggerParameter"] = { label="Parameter:"}
L.BUTTONS["addTrigger"] = { label="Neuen Auslöser hinzufügen", tooltip="Einen neuen Auslöser hinzufügen."}
L.BUTTONS["triggerSettings"] = { tooltip="Klicken, um die Auslöser-Einstellungen zu konfigurieren."}
L.BUTTONS["deleteTrigger"] = { tooltip="Klicken, um diesen Auslöser zu löschen."}
L.BUTTONS["editTriggerClasses"] = { tooltip="Klicken, um die Klassen, in der der Auslöser verwendet wird, zu bearbeiten."}
L.BUTTONS["addMainEvent"] = { label="Ereignis hinzufügen", tooltip="Wenn IRGENDEINES dieser Ereignisse auftritt und deren definierte Bedingungen geschehen, werden die Auslöser ausgeführt, außer es trifft eine festgelegte Ausnahme zu."}
L.BUTTONS["addTriggerException"] = { label="Ausnahme hinzufügen", tooltip="Wenn IRGENDEINE dieser Ausnahmen auftritt, wird der Auslöser nicht ausgeführt."}
L.BUTTONS["editEventConditions"] = { tooltip="Klicken, um für dieses Ereignis die Bedingungen zu bearbeiten."}
L.BUTTONS["deleteMainEvent"] = { tooltip="Klicken, um Ereignis zu entfernen."}
L.BUTTONS["addEventCondition"] = { label="Bedingung hinzufügen", tooltip="Wenn JEDE dieser Bedingungen für das ausgewählte Ereignis zutrifft, wird der Auslöser ausgeführt, außer es trifft eine festgelegte Ausnahme zu."}
L.BUTTONS["editCondition"] = { tooltip="Klicken, um Bedingung zu bearbeiten."}
L.BUTTONS["deleteCondition"] = { tooltip="Klicken, um Bedingung zu entfernen."}
L.BUTTONS["throttleList"] = { label="Unterdrückungs-Liste", tooltip="Benutzerdefinierte Unterdrückungszeit für festgelegte Fähigkeiten setzen."}
L.BUTTONS["mergeExclusions"] = { label="Ausschlüsse zusammenfügen", tooltip="Verhindert, dass festgelegte Fähigkeiten zusammengefügt werden."}
L.BUTTONS["skillSuppressions"] = { label="Fähigkeiten unterdrücken", tooltip="Unterdrückt Fähigkeiten durch ihren Namen."}
L.BUTTONS["skillSubstitutions"] = { label="Fähigkeiten ersetzen", tooltip="Ersetzt Fähigkeitsnamen mit angepassten Werten."}
L.BUTTONS["addSkill"] = { label="Fähigkeiten hinzufügen", tooltip="Neuen Fähigkeiten zur Liste hinzufügen."}
L.BUTTONS["deleteSkill"] = { tooltip="Klicken, um Fähigkeiten zu entfernen."}
L.EDITBOXES["skillName"] = { label="Fähigkeitsname:", tooltip="Name der Fähigkeit, die hinzugefügt werden soll."}
L.EDITBOXES["substitutionText"] = { label="Text ersetzen:", tooltip="Der Text, der für den Fähigkeitsnamen ersetzt werden soll."}
L.SLIDERS["skillThrottleTime"] = { label="Drosseln", tooltip="Die Nummer in Sekunden, um diese Fähigkeit zu drosseln."}
L.TRIGGER_DATA["SWING_DAMAGE"] = "Meleeschaden"
L.TRIGGER_DATA["RANGE_DAMAGE"] = "Fernkampfschaden"
L.TRIGGER_DATA["SPELL_DAMAGE"] = "Fähigkeitsschaden"
L.TRIGGER_DATA["GENERIC_DAMAGE"] = "Melee-/Fernkampf-/Fähigkeitsschaden"
L.TRIGGER_DATA["SPELL_PERIODIC_DAMAGE"] = "Periodischer Fähigkeitsschaden (DoT)"
L.TRIGGER_DATA["DAMAGE_SHIELD"] = "Schadensschild-Schaden"
L.TRIGGER_DATA["DAMAGE_SPLIT"] = "Aufgeteilter Schaden"
L.TRIGGER_DATA["ENVIRONMENTAL_DAMAGE"] = "Umwelt-Schaden"
L.TRIGGER_DATA["SWING_MISSED"] = "Melee-Fehlschlag"
L.TRIGGER_DATA["RANGE_MISSED"] = "Fernkampf-Fehlschlag"
L.TRIGGER_DATA["SPELL_MISSED"] = "Fähigkeits-Fehlschlag"
L.TRIGGER_DATA["GENERIC_MISSED"] = "Melee-/Fernkampf-/Fähigkeits-Fehlschlag"
L.TRIGGER_DATA["SPELL_PERIODIC_MISSED"] = "Periodischer Fähigkeits-Fehlschlag"
L.TRIGGER_DATA["SPELL_DISPEL_FAILED"] = "Dispel-Fehlschlag"
L.TRIGGER_DATA["DAMAGE_SHIELD_MISSED"] = "Schadensschild-Fehlschlag"
L.TRIGGER_DATA["SPELL_HEAL"] = "Heilung"
L.TRIGGER_DATA["SPELL_PERIODIC_HEAL"] = "Periodische Heilung (HoT)"
L.TRIGGER_DATA["SPELL_ENERGIZE"] = "Powergewinn"
L.TRIGGER_DATA["SPELL_PERIODIC_ENERGIZE"] = "Periodischer Powergewinn"
L.TRIGGER_DATA["SPELL_DRAIN"] = "Powerverlust"
L.TRIGGER_DATA["SPELL_PERIODIC_DRAIN"] = "Periodischer Powerverlust"
L.TRIGGER_DATA["SPELL_LEECH"] = "Power-Absaugen"
L.TRIGGER_DATA["SPELL_PERIODIC_LEECH"] = "Periodischer Power-Absaugen"
L.TRIGGER_DATA["SPELL_INTERRUPT"] = "Fähigkeit unterbrochen"
L.TRIGGER_DATA["SPELL_AURA_APPLIED"] = "Aura eingesetzt"
L.TRIGGER_DATA["SPELL_AURA_REMOVED"] = "Aura entfernt"
L.TRIGGER_DATA["SPELL_STOLEN"] = "Aura gestohlen"
L.TRIGGER_DATA["SPELL_DISPEL"] = "Aura Dispel"
L.TRIGGER_DATA["SPELL_AURA_REFRESH"] = "Aura aufgefrischt"
L.TRIGGER_DATA["SPELL_AURA_BROKEN_SPELL"] = "Aura gebrochen"
L.TRIGGER_DATA["ENCHANT_APPLIED"] = "Verzauberung eingesetzt"
L.TRIGGER_DATA["ENCHANT_REMOVED"] = "Verzauberung entfernt"
L.TRIGGER_DATA["SPELL_CAST_START"] = "Wirken gestartet"
L.TRIGGER_DATA["SPELL_CAST_SUCCESS"] = "Wirken erfolgreich"
L.TRIGGER_DATA["SPELL_CAST_FAILED"] = "Wirken fehlgeschlagen"
L.TRIGGER_DATA["SPELL_SUMMON"] = "Beschwören"
L.TRIGGER_DATA["SPELL_CREATE"] = "Erstellen"
L.TRIGGER_DATA["PARTY_KILL"] = "Todesstoß"
L.TRIGGER_DATA["UNIT_DESTROYED"] = "Einheit zerstört"
L.TRIGGER_DATA["SPELL_EXTRA_ATTACKS"] = "Zusätzliche Attacken"
L.TRIGGER_DATA["UNIT_HEALTH"] = "Lebenspunkteveränderung"
L.TRIGGER_DATA["UNIT_POWER"] = "Powerveränderung"
L.TRIGGER_DATA["sourceName"] = "Quellenname"
L.TRIGGER_DATA["sourceAffiliation"] = "Quellenzugehörigkeit"
L.TRIGGER_DATA["sourceReaction"] = "Quellenreaktion"
L.TRIGGER_DATA["sourceControl"] = "Quellenkontrolle"
L.TRIGGER_DATA["sourceUnitType"] = "Quellentyp"
L.TRIGGER_DATA["recipientName"] = "Empfängername"
L.TRIGGER_DATA["recipientAffiliation"] = "Empfängerzugehörigkeit"
L.TRIGGER_DATA["recipientReaction"] = "Empfängerreaktion"
L.TRIGGER_DATA["recipientControl"] = "Empfängerkontrolle"
L.TRIGGER_DATA["recipientUnitType"] = "Empfängertyp"
L.TRIGGER_DATA["skillID"] = "Fähigkeits-ID"
L.TRIGGER_DATA["skillName"] = "Fähigkeitsname"
L.TRIGGER_DATA["skillSchool"] = "Fähigkeitsschule"
L.TRIGGER_DATA["extraSkillID"] = "Zusätzliche Fähigkeits-ID"
L.TRIGGER_DATA["extraSkillName"] = "Zusätzlicher Fähigkeitsname"
L.TRIGGER_DATA["extraSkillSchool"] = "Zusätzliche Fähigkeitsschule"
L.TRIGGER_DATA["amount"] = "Menge"
L.TRIGGER_DATA["overkillAmount"] = "Menge über Tod"
L.TRIGGER_DATA["damageType"] = "Schadensart"
L.TRIGGER_DATA["resistAmount"] = "Widerstandene Menge"
L.TRIGGER_DATA["blockAmount"] = "Geblockte Menge"
L.TRIGGER_DATA["absorbAmount"] = "Absobierte Menge"
L.TRIGGER_DATA["isCrit"] = "Krit"
L.TRIGGER_DATA["isGlancing"] = "Gestreifter Treffer"
L.TRIGGER_DATA["isCrushing"] = "Schmetternder Stoß"
L.TRIGGER_DATA["extraAmount"] = "Extra Menge"
L.TRIGGER_DATA["missType"] = "Verfehlen-Typ"
L.TRIGGER_DATA["hazardType"] = "Gefahrentyp"
L.TRIGGER_DATA["powerType"] = "Power-Typ"
L.TRIGGER_DATA["auraType"] = "Auren-Typ"
L.TRIGGER_DATA["threshold"] = "Schwelle"
L.TRIGGER_DATA["unitID"] = "Einheit ID"
L.TRIGGER_DATA["unitReaction"] = "Einheit Reaktion"
L.TRIGGER_DATA["itemID"] = "Gegenstand ID"
L.TRIGGER_DATA["itemName"] = "Gegenstandsname"
L.TRIGGER_DATA["activeTalents"] = "Aktive Talente"
L.TRIGGER_DATA["buffActive"] = "Buff Aktiv"
L.TRIGGER_DATA["buffInactive"] = "Buff Inaktiv"
L.TRIGGER_DATA["currentCP"] = "Momentane Combo Punkte"
L.TRIGGER_DATA["currentPower"] = "Momentane Energie"
L.TRIGGER_DATA["inCombat"] = "Im Kampf"
L.TRIGGER_DATA["recentlyFired"] = "Auslöser kürzlich aktiviert"
L.TRIGGER_DATA["trivialTarget"] = "Triviales Ziel"
L.TRIGGER_DATA["unavailableSkill"] = "Fehlende Fähigkeit"
L.TRIGGER_DATA["warriorStance"] = "Krieger-Haltung"
L.TRIGGER_DATA["zoneName"] = "Zonenname"
L.TRIGGER_DATA["zoneType"] = "Zonenart"
L.TRIGGER_DATA["eq"] = "ist gleich wie"
L.TRIGGER_DATA["ne"] = "ist nicht gleich wie"
L.TRIGGER_DATA["like"] = "ist wie"
L.TRIGGER_DATA["unlike"] = "ist nicht wie"
L.TRIGGER_DATA["lt"] = "ist kleiner als"
L.TRIGGER_DATA["gt"] = "ist größer als"
L.TRIGGER_DATA["affiliationMine"] = "Mein"
L.TRIGGER_DATA["affiliationParty"] = "Gruppenmitglied"
L.TRIGGER_DATA["affiliationRaid"] = "Schlachtzugsmitglied"
L.TRIGGER_DATA["affiliationOutsider"] = "Außenstehender"
L.TRIGGER_DATA["affiliationTarget"] = "Ziel"
L.TRIGGER_DATA["affiliationFocus"] = "Fokus"
L.TRIGGER_DATA["affiliationYou"] = "Du"
L.TRIGGER_DATA["reactionFriendly"] = "Freundlich"
L.TRIGGER_DATA["reactionNeutral"] = "Neutral"
L.TRIGGER_DATA["reactionHostile"] = "Feindlich"
L.TRIGGER_DATA["controlServer"] = "Server"
L.TRIGGER_DATA["controlHuman"] = "Mensch"
L.TRIGGER_DATA["unitTypePlayer"] = "Spieler"
L.TRIGGER_DATA["unitTypeNPC"] = "NPC"
L.TRIGGER_DATA["unitTypePet"] = "Begleiter"
L.TRIGGER_DATA["unitTypeGuardian"] = "Wächter"
L.TRIGGER_DATA["unitTypeObject"] = "Objekt"
L.TRIGGER_DATA["auraTypeBuff"] = "Buff"
L.TRIGGER_DATA["auraTypeDebuff"] = "Debuff"
L.TRIGGER_DATA["zoneTypeArena"] = "Arena"
L.TRIGGER_DATA["zoneTypePvP"] = "Schlachtfeld"
L.TRIGGER_DATA["zoneTypeParty"] = "5-Mann Instanz"
L.TRIGGER_DATA["zoneTypeRaid"] = "Schlachtzug-Instanz"
L.TRIGGER_DATA["booleanTrue"] = "Richtig"
L.TRIGGER_DATA["booleanFalse"] = "Falsch"
