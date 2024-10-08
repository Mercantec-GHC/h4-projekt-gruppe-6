|            | Scrum Master | Product Owner | Kundechef |
| ---------- | ------------ | ------------- | --------- |
| **Uge 32** | Alexander    | Reimar        | Philip    |
| **Uge 33** | Philip       | Alexander     | Reimar    |
| **Uge 34** | Reimar       | Philip        | Alexander |
| **Uge 35** | Alexander    | Reimar        | Philip    |
| **Uge 36** | Philip       | Alexander     | Reimar    |
| **Uge 37** | Reimar       | Philip        | Alexander |

# Daglig Logbog Uge 32

Terms:
SM - Scrum Master
PO - Product Owner
KC - Kundechef

## Onsdag

**SM(Alexander):** Var tilstede, skabte denne logbog, er gode vibes på holdet.

**PO(Reimar):** Sat git repository op med kravspec osv., oprettet tasks, planlagt præsentationsmøde

**KC(Philip):** Vi havde møde med vores programmøre der laver vores ide. Jeg hjalp dem med de spørgsmål de havde

## Torsdag

**SM(Alexander):** Hjalp lidt til med Figma og tilføjede scene transitions imellem menu'erne - Det meste af dagen var syg

**PO(Reimar):** Hjalp til med Figma og lavede diverse sider og gjorde dem klar til scene transitions

**KC(Philip):** Havde en kort snak med daniel fra programmerings gruppen

## Fredag

**SM(Alexander):** Sad med til Møde som Kunde sammen med Reimar.

**PO(Reimar):** Var til kundemøder

**KC(Philip):** Sov over mig, så jeg kom ikke til mødet med programmerings gruppen. Dog så jeg stadig deres design og jeg var virkelig tilfreds!!

# Uge 33

## Mandag

**PO(Alexander):** mødte op

**KC(Reimar):** Sat backenden op med database og en healthcheck controller

**SM(Philip):** Vi snakkede om opsætning i gruppen og lavede filstruktur

## Tirsdag

**PO(Alexander):** Var syg :))))

**KC(Reimar):** Deployet til production og lavet release script, startede på Rust Backend

**SM(Philip):** Login blev lavet og jeg fik besked af programmerings gruppen at de manglede en liste over beatboxers. Den sendte jeg til dem

## Onsdag

**PO(Alexander):** Hjalp til med integration tests i bash

**KC(Reimar):** Lavede integration tests i bash

**SM(Philip):** Vi sad sammen i gruppen og rodedet med scripts til at teste vores loginsystem. Det virkede til sidst

## Torsdag

**PO(Alexander):** Manglende pga. sygdom

**KC(Reimar):** Implementeret JWT verifikation i rust-backenden

**SM(Philip):** Var med til et møde sammen med reimer da programmeringsgruppen skulle bruge hjælp. Tilføjede selv authorization på swagger appikationen

## Fredag

**PO(Alexander):** Manglende pga. kommunemøde

**KC(Reimar):** Lavet model og routes til oprettelse/sletning af favoritter i rust

**SM(Philip):** 

# Uge 34

## Mandag

**KC(Alexander):** Mødte op, lavede hurlumhaj, lærte om Flutter. Geninstallerede min laptop fordi Windows var træls. Fik sat alle værktøjerne op på Linux Mint

**SM(Reimar):** Kørte gennem flutter-tutorial

**PO(Philip):** Flutter tutorial

## Tirsdag

**KC(Alexander):** Ramt af sygdom, fucking tirsdage

**SM(Reimar):** Tilføjet kort samt login/register-side til vores flutter app

**PO(Philip):** start på menu som kunderne bad om

## Onsdag

**KC(Alexander):** Mødte lidt sent, kiggede Reimar's kode igennem, pointerede et issue med email-validation (kan nok løses med lidt Regex)

**SM(Reimar):** Koblet flutter app sammen med vorese backend API til login/signup

**PO(Philip):** færdig med side-menu som funger på alle sider.

## Torsdag

**KC(Alexander):** Blev tæsket igennem VIM og arbejdede med Reimar på Favorites-featuren, inklusiv Rust server og database migration

**SM(Reimar):** Tilføjet at favoritter bliver vist på map

**PO(Philip):** færdig med side-menu som funger på alle sider.

## Fredag

**KC(Alexander):** Afholdte møde med vores udviklergruppe, De planlægger at lave core gameplay features i uge 35

**SM(Reimar):** Begyndt på implementation af name/description på favorites

**PO(Philip):** Havde møde med Freja. De bad om at når man opdaterer en brugers info. så skal man kunne opdatere det hele. Før havde vi snakket oma at opdatere password for sig selv. og alt andet for sig selv


# Uge 35

## Mandag

**SM(Alexander):** Satte SCRUM møder op for denne og følgende uger. Var ellers syg.

**PO(Reimar):** Færdiggjort implementation af name/description på favorites, lavet bottom sheet når man klikker på en lokation, ændret udseendet på location pins

**KC(Philip):** Ingen kontakt fra programmeringsgruppen. Behøves heller ikke på nuværende tidspunkt*

## Tirsdag

**SM(Alexander):** Var til tandlæge

**PO(Reimar):** Implementeret favorit-knap på location info bottom sheet, optimeret API requests

**KC(Philip):** Alt opdateres på profil i db, men ikke rigtigt vist i flutter

## Onsdag

**SM(Alexander):**

**PO(Reimar):** Downloaded turist-guides for alle byer i Danmark

**KC(Philip):** vist ordenligt på flutter og fandt viden omkring søgefunktion og hvordan man bruger openstreetmapapi's search funktion

## Torsdag

**SM(Alexander):** Samarbejdede med Reimar omkring Refresh-tokens, mest med ide-fasen

**PO(Reimar):** Begyndt på implementering af refresh tokens, fikset en fejl med en openssl dependency til vores release-flow

**KC(Philip):** Havde et møde med programmeringsgruppen hvor de viste at de havde lavet en lobby hvor 2 mobiler kunne forbinde til den lobby. Mega fedt!

## Fredag

**SM(Alexander):** Holdt kundemøder

**PO(Reimar):** Holdt kundemøder

**KC(Philip):** søgefunktion med det første hit i et array lavet. Det skal ændres så man kan vælge alt fra valgmulighederne openstreetmapapi'en giver

# Uge 36

## Mandag

**PO(Alexander):**

**KC(Reimar):** Færdiggjort refresh token implementation

**SM(Philip):** Fandt ud af hvem der lavede hvad. Jeg arbejdede videre på søgefunktion for at optimere hvad output er. gutterne lavede reviews

## Tirsdag

**PO(Alexander):** Pair-programmede med Reimar om nedenstående features

**KC(Reimar):** Implementeret reviews i rust backenden, fået vist dem som location pins på kortet

**SM(Philip):** Blev færdig med søgefunktion og videoen til billeder blev sendt ud, som jeg kiggede lidt på. søgefunktionen er stadig lort, men der er noget der hedder osm.org vi kan kigge på. Den virker dog så vi besluttede at lave andet funktionallitet der var vigtigere

## Onsdag

**PO(Alexander):** Pair-programmede med Reimar om nedenstående features

**KC(Reimar):** Implementeret review-liste når man klikker ind på én

**SM(Philip):** arbejde videre med billeder. fik det næsten til at virke på API lag

## Torsdag

**PO(Alexander):** Pair-programmede med Reimar om nedenstående features

**KC(Reimar):** Lavet create review-side, tilføjet stjerner til review-liste

**PO(Philip):** havde møde med programmeringsgruppen og så de fede ting de havde lavet. API med billeder og cloudflare fuldkommen sat op

## Fredag

**PO(Alexander):** Hjalp med kundemøder 

**KC(Reimar):** Holdt kundemøder

**SM(Philip):** Kan ikke få sendt noget igennem fra flutter til api med lorte billede. HJÆÆÆÆÆÆÆÆÆÆÆÆÆÆÆLP. 

# Uge 37

## Mandag

**KC(Alexander):**

**SM(Reimar):**

**PO(Philip):**

## Tirsdag

**KC(Alexander):**

**SM(Reimar):**

**PO(Philip):**

## Onsdag

**KC(Alexander):**

**SM(Reimar):**

**PO(Philip):**

## Torsdag

**KC(Alexander):**

**SM(Reimar):**

**PO(Philip):**

## Fredag

**KC(Alexander):**

**SM(Reimar):**

**PO(Philip):**

## Fredag

**KC(Alexander):**

**SM(Reimar):**

**PO(Philip):**

