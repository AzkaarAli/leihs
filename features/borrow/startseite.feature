# language: de

Funktionalität: Startseite

  Um einen Überblick über das ausleihbare Inventar zu erhalten
  möchte ich als Ausleiher
  einen Einstieg/Übersicht über das ausleihbare Inventar

  Szenario: Startseite
    Angenommen persona "Normin" existing
    Und man ist eingeloggt als "Normin"
    Und man befindet sich auf der Startseite
    Dann sieht man genau die für den User bestimmte Haupt-Kategorien mit Bild und Namen
    Und man sieht die Überschrift "Hauptkategorien"

  @javascript
  Szenario: Haupt-Kategorien aufklappen
    Angenommen persona "Normin" existing
    Und man ist eingeloggt als "Normin"
    Und man befindet sich auf der Startseite
    Wenn ich über eine Hauptkategorie mit Kindern fahre
    Dann sehe ich die Kinder dieser Hauptkategorie
    Wenn ich eines dieser Kinder anwähle
    Dann lande ich in der Modellliste für diese Kategorie
