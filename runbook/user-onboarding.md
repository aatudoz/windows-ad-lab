# Uuden käyttäjän luonti: aatu.lab

Kun uusi työntekijä aloittaa, näin hänelle luodaan AD-tunnus.
Useammalle kuin parille käyttäjälle kerralla: käytä skriptiä
(alaosio)

## Mitä HR:ltä tarvitaan

Ennen kuin teet mitään, varmista että tiketissä on:
- Etunimi ja sukunimi
- Osasto (oltava olemassa oleva OU polun OU=Users,OU=AATU alla)
- Tehtävänimike
- Aloituspäivä

Jos jokin puuttuu, good luck.

## Yksittäinen käyttäjä (manuaalisesti)

1. Avaa ADUC, mene OU=AATU > Users > [osasto]
2. Oikea klikkaus OU:n päällä > New > User
3. Käyttäjätunnus: etunimen alkukirjain + sukunimi, pienillä,
   vain ASCII-merkit (Anna Hämäläinen -> ahamalainen)
4. Väliaikainen salasana, valitse "User must change password at
   next logon"
5. Luonnin jälkeen avaa käyttäjä > Member Of > lisää osastoryhmään
   (GG_[Osasto]_Staff) ja kaikkien työntekijöiden ryhmään
6. Täytä Title ja Department -kentät

## Useita käyttäjiä (skripti)

Useamman käyttäjän luontiin käytä New-AATUUser.ps1 -skriptiä.

CSV:n muoto, otsikot täsmälleen näin:

    FirstName,LastName,Department,JobTitle

Aja:

    .\New-AATUUser.ps1 -CsvPath .\new-users.csv

Skripti on idempotentti, eli jos käyttäjä on jo olemassa, se ohitetaan
varoituksella eikä kaadu. Turvallista ajaa uudelleen. Skripti lisää
käyttäjät myös oikeisiin ryhmiin automaattisesti.

## Tarkistus

Sulje tiketti vasta kun olet varmistanut tunnuksen:

    Get-ADUser <tunnus> -Properties MemberOf, Department, Title |
        Select Name, Enabled, Department, Title, MemberOf

Pitäisi näkyä: Enabled = True, oikea osasto ja nimike, jäsenyys
sekä osastoryhmässä että kaikkien työntekijöiden ryhmässä.

## Väärin luodun tunnuksen poisto

    Remove-ADUser -Identity <tunnus>

Varmista ADUC:sta että tunnus on poistunut ennen uudelleenluontia.

## Yleisiä ongelmia

- Skripti kaatui yhden käyttäjän kohdalla: yleensä erikoismerkki
  nimessä (heittomerkki, yhdysviiva). Luo se yksi käsin.
- Tunnus luotu mutta ei voi kirjautua: tarkista Enabled-tila.
- Osastoryhmä puuttuu: uusi osasto josta IT ei tiennyt. Luo
  GG_[Osasto]_Staff ennen skriptin ajoa.
