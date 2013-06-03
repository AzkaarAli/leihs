# language: de

Funktionalität: Bestellung

  Um Gegenstände ausleihen zu können
  möchte ich als Ausleiher
  die möglichkeit haben Modelle zu bestellen

  Szenario: Bestellfensterchen
    Angenommen persona "Normin" existing
    Und man ist eingeloggt als "Normin"
    Dann sehe ich das Bestellfensterchen

  Szenario: Kein Bestellfensterchen
    Angenommen persona "Normin" existing
    Und man ist eingeloggt als "Normin"
    Und man befindet sich auf der Bestellübersicht
    Dann sehe ich kein Bestellfensterchen
