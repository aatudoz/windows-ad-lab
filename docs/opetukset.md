# Vianselvitys ja opitut asiat

Labran tekemisessä tuli vastaan aika monta ongelmaa. Osa oli pieniä
säätöjä, mutta varsinkin AD CS vei jonkin verran aikaa.
Tässä yleisimmät ongelmat, niiden syyt ja miten ne lopulta ratkesivat.

## Virtuaalikone käynnistyi PXE-bootilla

**Oire:** Virtuaalikone ei bootannut asennusmedialta vaan jäi kohtaan
"Start PXE over IPv4".

**Syy:** Hyper-V:n Gen 2 -virtuaalikoneessa verkkokortti oli
käynnistysjärjestyksessä DVD-aseman edellä.

**Ratkaisu:** Vaihdoin Hyper-V:n laiteohjelmistoasetuksista DVD-aseman
ensimmäiseksi boottilaitteeksi. Sen jälkeen asennus käynnistyi
normaalisti.

## Staattinen IP meni päällekkäin

**Oire:** Verkkoyhteys ei toiminut ja `ipconfig` näytti IP-osoitteen
tilaksi Duplicate.

**Syy:** Laitoin vahingossa palvelimen IP-osoitteeksi reitittimen
osoitteen `192.168.1.1`.

**Ratkaisu:** Vaihdoin osoitteeksi `192.168.1.200`, joka oli
DHCP-alueen ulkopuolella. Tästä oppi sen, että kannattaa aina
tarkistaa verkon nykyiset osoitteet ennen kuin laittaa staattisen IP:n.

## AD CS – varmenteen enrollment epäonnistui

Tämä oli koko labran pahin ongelma ja tähän meni helposti eniten aikaa.

**Oire:** Varmenteen pyytäminen epäonnistui jatkuvasti virheeseen
`CERTSRV_E_TEMPLATE_DENIED`. Lisäksi varmennepohjat näkyivät välillä
Status unavailable -tilassa.

**Mitä kokeilin ensin:**

- Vaihdoin varmennepohjan yhteensopivuusasetukset pois vanhasta
  Server 2003 -tasosta
- Lisäsin Domain Computers -ryhmälle Enroll-oikeudet sekä templateen
  että CA:han
- Kävin oikeuksia läpi monta kertaa, koska oletin ongelman olevan niissä

Noista mikään ei kuitenkaan korjannut itse enrollment-virhettä.

**Juurisyy:** Lopulta selvisi, että palvelimen tietokonetili
`LAB-SERVER01$` ei ollut edes Domain Computers -ryhmässä, vaikka kone
oli liitetty domainiin. Eli kaikki oikeudet annettiin ryhmälle, johon
pyytävä tili ei oikeasti kuulunut.

Tämän näki PowerShellillä:

Get-ADComputer LAB-SERVER01 -Properties MemberOf |
    Select -ExpandProperty MemberOf

**Ratkaisu:** Lisäsin koneen takaisin Domain Computers -ryhmään ja
käynnistin palvelimen uudelleen, jotta Kerberos-token päivittyi.

**Opetus:** Jos oikeuksien muuttaminen ei vaikuta yhtään mihinkään,
kannattaa tarkistaa että oikea käyttäjä tai tietokonetili kuuluu siihen
ryhmään, jolle oikeudet annetaan. Tässä myös helposti unohtuu, että
Local Machine -storeen pyydetyn varmenteen pyytää koneen tili eikä
sisäänkirjautunut käyttäjä.

## SSMS ei yhdistänyt SQL Serveriin

**Oire:** SSMS antoi virheen "The certificate chain was issued by an
authority that is not trusted".

**Syy:** Uudemmat SSMS-versiot käyttävät oletuksena salattua yhteyttä.
SQL Serverillä taas oli vain itse allekirjoitettu varmenne, johon SSMS
ei luottanut.

**Ratkaisu:** Vaihdoin yhteysasetuksista `Encryption = Optional` ja
laitoin päälle Trust server certificate. Oikeassa tuotantoympäristössä
parempi ratkaisu olisi käyttää domainin CA:n myöntämää varmennetta.

## IIS:stä ei löytynyt Bindings-valintaa

**Oire:** En löytänyt IIS Managerista kohtaa Bindings.

**Syy:** Olin valinnut palvelimen enkä itse sivustoa. Bindings näkyy
vain silloin, kun yksittäinen sivusto on valittuna.

**Ratkaisu:** Avasin Sites-kohdan ja valitsin `AATU-Portal`-sivuston,
jonka jälkeen Bindings tuli näkyviin Actions-paneeliin.

## SQL-varmuuskopio epäonnistui

**Oire:** `BACKUP DATABASE` -komento epäonnistui.

**Syy:** Käytin tietokannan nimeä, joka ei vastannut oikeasti
asennettua tietokantaa.

**Ratkaisu:** Korjasin komennon käyttämään oikeaa tietokannan nimeä.
Tässä huomasi hyvin sen, että nimet kannattaa pitää kaikkialla samoina
— tietokannoissa, palvelimissa, varmenteissa ja dokumentaatiossa —
muuten tulee helposti turhaa sekoilua.
