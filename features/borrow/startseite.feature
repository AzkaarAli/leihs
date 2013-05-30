# language: de

Funktionalität: Startseite

  Um einen Überblick über das ausleihbare Inventar zu erhalten
  möchte ich als Ausleiher
  einen Einstieg/Übersicht über das ausleihbare Inventar

  @javascript
  Szenario: Startseite
    Angenommen persona "Normin" existing
    Und man ist "Normin"
    Dann befindet man sich auf der Startseite
    Und man sieht genau die für den User bestimmte Haupt-Kategorien mit Bild und Namen
    Und man sieht die Überschrift "Hauptkategorien"

  @javascript
  Szenario: Haupt-Kategorien aufklappen
    Angenommen persona "Normin" existing
    Und man ist "Normin"
    Und man befindet sich auf der Startseite
    Wenn ich über eine Hauptkategorie fahre
    Dann seh ich die Kinder dieser Hauptkategorie
    Wenn ich eines dieser Kinder anwählen
    Dann lande ich in der Modellliste für diese Kategorie
