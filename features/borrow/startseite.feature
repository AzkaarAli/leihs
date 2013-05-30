# language: de

Funktionalität: Startseite

  Um einen Überblick über das ausleihbare Inventar zu erhalten
  möchte ich als Ausleiher
  einen Einstieg/Übersicht über das ausleihbare Inventar

  Szenario: Startseite
    Angenommen man ist "Normin"
    Wenn man hat sich eingeloggt hat
    Dann befindet man sich auf der Startseite
    Und man sieht die Haupt-Kategorien mit Bild und Namen
    Und man sieht die Überschrift "Hauptkategorien"

  Szenario: Haupt-Kategorien aufklappen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Startseite
    Wenn ich über eine Hauptkategorie fahre
    Dann seh ich die Kinder dieser Hauptkategorie
    Wenn ich eines dieser Kinder anwählen
    Dann lande ich in der Modellliste für diese Kategorie
