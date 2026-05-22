# Skriptit

## New-AATUUser.ps1

PowerShell-skripti, joka luo Active Directory -käyttäjätunnuksia
massana CSV-tiedostosta. Vastaa tilannetta, jossa HR toimittaa
listan uusista työntekijöistä ja IT luo heille tunnukset.

### Mitä skripti tekee

- Lukee käyttäjät CSV:stä (etunimi, sukunimi, osasto, tehtävänimike)
- Luo tunnuksen oikeaan osasto-OU:hun
- Muodostaa käyttäjätunnuksen (etunimen alkukirjain + sukunimi),
  ä/ö/å muunnetaan ASCII-muotoon (koska käytössä oli USA versio windowsista)
- Lisää käyttäjän osastoryhmään ja kaikkien työntekijöiden ryhmään
- Asettaa väliaikaisen salasanan, joka on vaihdettava heti
  ensimmäisellä kirjautumisella

Skripti on idempotentti, eli jos käyttäjä on jo olemassa, se ohitetaan
varoituksella eikä skripti kaadu. Turvallista ajaa uudelleen.

### Käyttö

    .\New-AATUUser.ps1 -CsvPath ".\new-users.csv"

### CSV:n muoto

Otsikkorivin on oltava täsmälleen:

    FirstName,LastName,Department,JobTitle

Esimerkki: katso new-users.csv tässä kansiossa.
