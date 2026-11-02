# Spordivaim – Elm veebileht

Algklasside (1.–4. klass) spordiklubi leht: trennide ajakava, hooajad, laagrid ja treenerite kalender.

## Failid

```
spordivaim/
├── elm.json          Elm 0.19.1 projekti seaded ja sõltuvused
├── index.html        Leht, mis laeb elm.js ja style.css
├── style.css         Kujundus (hele ja tume režiim)
└── src/Main.elm      Kogu rakendus
```

## Käivitamine

1. Paigalda Elm 0.19.1: https://guide.elm-lang.org/install/elm.html
   (või `npm install -g elm`).
2. Kompileeri projekti kaustas:

   ```
   elm make src/Main.elm --output=elm.js
   ```

3. Ava leht kohaliku serveriga, näiteks:

   ```
   python3 -m http.server 8000
   ```

   ja mine aadressile http://localhost:8000

Arenduse ajal on mugav `elm-live`:

```
npm install -g elm-live
elm-live src/Main.elm --open -- --output=elm.js
```

Tootmiseks (väiksem fail):

```
elm make src/Main.elm --optimize --output=elm.js
```

Avalikuks avaldamiseks on vaja kolme faili: `index.html`, `style.css` ja `elm.js`
(sobib GitHub Pages, Netlify, Firebase Hosting jne).

## Andmete muutmine

Kõik andmed on faili `src/Main.elm` alguses:

- `trainings` – trennid (päev 0 = esmaspäev … 6 = pühapäev, algus, lõpp, klass, spordiala, treener, koht)
- `coaches` – treenerite nimed kalendri filtri jaoks
- `camps` – laagrid (kuupäev kujul AAAAKKPP, nt `20261228`)
- `seasons` – hooajad ja spordialad
- `noTrainingMonths` – kuud, mil trenne ei toimu (praegu 6, 7, 8 = suvevaheaeg)

## Gmaili sisselogimine (hiljem)

Nupud „Logi sisse“ on praegu välja lülitatud. Elmis tehakse Google’i sisselogimine tavaliselt
nii: kasutada Firebase Authentication’it (Google provider) JavaScripti poolel ja ühendada see
Elmiga **portide** (`port`) kaudu. Elm saab kasutaja e-posti ja rolli (treener / lapsevanem)
ning näitab selle põhjal vastavat vaadet. Kui oled valmis, aitan selle lisada.
