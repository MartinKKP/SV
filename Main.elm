module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (attribute, class, disabled, href, id, selected, style, title, value)
import Html.Events exposing (onClick, onInput)
import Task
import Time



-- ANDMED (muuda siin trenne, laagreid ja hooaegu)


type alias Group =
    { id : Int, name : String, cls : String }


type alias Training =
    { dow : Int -- 0 = esmaspäev ... 6 = pühapäev
    , start : String
    , end : String
    , group : Int
    , sport : String
    , coach : String
    , place : String
    }


type alias Camp =
    { name : String
    , start : Int -- kuupäev kujul AAAAKKPP
    , end : Int
    , desc : String
    , place : String
    }


type alias Season =
    { name : String
    , months : List Int
    , range : String
    , cls : String
    , sports : List String
    }


groups : List Group
groups =
    [ Group 1 "1. klass" "g1"
    , Group 2 "2. klass" "g2"
    , Group 3 "3. klass" "g3"
    , Group 4 "4. klass" "g4"
    ]


coaches : List String
coaches =
    [ "Annika" ]


trainings : List Training
trainings =
    [ Training 0 "16:00" "17:00" 3 "Saalijalgpall" "Annika" "Spordisaal A"
    , Training 0 "17:00" "18:00" 4 "Võrkpall" "Annika" "Spordisaal A"
    , Training 1 "16:00" "17:15" 1 "Mängud ja koordinatsioon" "Annika" "Spordisaal B"
    , Training 1 "17:15" "18:15" 2 "Kergejõustik" "Annika" "Spordisaal B"
    , Training 3 "16:00" "17:00" 3 "Saalijalgpall" "Annika" "Spordisaal A"
    , Training 3 "17:00" "18:00" 4 "Võrkpall" "Annika" "Spordisaal A"
    , Training 4 "16:00" "17:15" 1 "Võimlemine" "Annika" "Spordisaal B"
    , Training 4 "17:15" "18:15" 2 "Võimlemine" "Annika" "Spordisaal B"
    ]


camps : List Camp
camps =
    [ Camp "Jõululaager" 20261228 20261230 "Saalimängud, võimlemine ja jõulune teatevõistlus." "Spordisaalid A ja B"
    , Camp "Talvevaheaja laager" 20270215 20270219 "Suusatamine, uisutamine ja talvised välimängud." "Spordikeskus ja park"
    , Camp "Suvelaager" 20270621 20270625 "Rannavõrkpall, kergejõustik ja seiklusmängud." "Rannaala"
    ]


seasons : List Season
seasons =
    [ Season "Sügis" [ 9, 10, 11 ] "september–november" "s-autumn" [ "Kergejõustik", "Orienteerumine", "Jooksumängud" ]
    , Season "Talv" [ 12, 1, 2 ] "detsember–veebruar" "s-winter" [ "Saalijalgpall", "Suusatamine", "Uisutamine" ]
    , Season "Kevad" [ 3, 4, 5 ] "märts–mai" "s-spring" [ "Võimlemine", "Võrkpall", "Pallimängud" ]
    , Season "Suvi" [ 6, 7, 8 ] "juuni–august" "s-summer" [ "Trenne ei toimu (suvevaheaeg)", "Suvelaager: rannavõrkpall ja kergejõustik" ]
    ]


{-| Suvevaheajal (juuni–august) trenne ei toimu.
-}
noTrainingMonths : List Int
noTrainingMonths =
    [ 6, 7, 8 ]


dayNames : List String
dayNames =
    [ "Esmaspäev", "Teisipäev", "Kolmapäev", "Neljapäev", "Reede", "Laupäev", "Pühapäev" ]


shortDays : List String
shortDays =
    [ "E", "T", "K", "N", "R", "L", "P" ]


monthNames : List String
monthNames =
    [ "jaanuar", "veebruar", "märts", "aprill", "mai", "juuni", "juuli", "august", "september", "oktoober", "november", "detsember" ]



-- MUDEL


type alias Model =
    { today : Int
    , viewYear : Int
    , viewMonth : Int
    , selected : Int
    , group : Int -- 0 = kõik klassid
    , coach : String -- "" = kõik treenerid
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { today = 0
      , viewYear = 2026
      , viewMonth = 11
      , selected = 0
      , group = 0
      , coach = ""
      }
    , Task.map2 Tuple.pair Time.here Time.now
        |> Task.perform GotNow
    )



-- UUENDUS


type Msg
    = GotNow ( Time.Zone, Time.Posix )
    | PrevMonth
    | NextMonth
    | GoToday
    | SelectDay Int
    | SelectGroup Int
    | SelectCoach String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotNow ( zone, posix ) ->
            let
                y =
                    Time.toYear zone posix

                m =
                    monthNumber (Time.toMonth zone posix)

                d =
                    Time.toDay zone posix

                k =
                    toKey y m d
            in
            ( { model | today = k, selected = k, viewYear = y, viewMonth = m }, Cmd.none )

        PrevMonth ->
            if model.viewMonth == 1 then
                ( { model | viewYear = model.viewYear - 1, viewMonth = 12 }, Cmd.none )

            else
                ( { model | viewMonth = model.viewMonth - 1 }, Cmd.none )

        NextMonth ->
            if model.viewMonth == 12 then
                ( { model | viewYear = model.viewYear + 1, viewMonth = 1 }, Cmd.none )

            else
                ( { model | viewMonth = model.viewMonth + 1 }, Cmd.none )

        GoToday ->
            if model.today == 0 then
                ( model, Cmd.none )

            else
                let
                    ( y, m, _ ) =
                        fromKey model.today
                in
                ( { model | selected = model.today, viewYear = y, viewMonth = m }, Cmd.none )

        SelectDay k ->
            ( { model | selected = k }, Cmd.none )

        SelectGroup g ->
            ( { model | group = g }, Cmd.none )

        SelectCoach c ->
            ( { model | coach = c }, Cmd.none )


monthNumber : Time.Month -> Int
monthNumber month =
    case month of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12



-- KUUPÄEVAD


toKey : Int -> Int -> Int -> Int
toKey y m d =
    y * 10000 + m * 100 + d


fromKey : Int -> ( Int, Int, Int )
fromKey k =
    ( k // 10000, modBy 10000 k // 100, modBy 100 k )


isLeap : Int -> Bool
isLeap y =
    (modBy 4 y == 0 && modBy 100 y /= 0) || modBy 400 y == 0


daysInMonth : Int -> Int -> Int
daysInMonth y m =
    case m of
        2 ->
            if isLeap y then
                29

            else
                28

        4 ->
            30

        6 ->
            30

        9 ->
            30

        11 ->
            30

        _ ->
            31


daysFromCivil : Int -> Int -> Int -> Int
daysFromCivil y m d =
    let
        y2 =
            if m <= 2 then
                y - 1

            else
                y

        era =
            y2 // 400

        yoe =
            y2 - era * 400

        mp =
            if m > 2 then
                m - 3

            else
                m + 9

        doy =
            (153 * mp + 2) // 5 + d - 1

        doe =
            yoe * 365 + yoe // 4 - yoe // 100 + doy
    in
    era * 146097 + doe - 719468


{-| 0 = esmaspäev ... 6 = pühapäev
-}
dowOf : Int -> Int
dowOf k =
    let
        ( y, m, d ) =
            fromKey k
    in
    modBy 7 (daysFromCivil y m d + 3)


pad2 : Int -> String
pad2 n =
    String.padLeft 2 '0' (String.fromInt n)


dateLabel : Int -> String
dateLabel k =
    let
        ( y, m, d ) =
            fromKey k
    in
    String.fromInt d ++ "." ++ pad2 m ++ "." ++ String.fromInt y


nth : Int -> List String -> String
nth i list =
    list |> List.drop i |> List.head |> Maybe.withDefault ""


groupById : Int -> Group
groupById id =
    groups
        |> List.filter (\g -> g.id == id)
        |> List.head
        |> Maybe.withDefault (Group 0 "" "")



-- SÜNDMUSED


type Event
    = TrainingEv Training
    | CampEv Camp


eventsOn : Model -> Int -> List Event
eventsOn model k =
    let
        ( _, m, _ ) =
            fromKey k

        campEvents =
            camps
                |> List.filter (\c -> k >= c.start && k <= c.end)
                |> List.map CampEv

        trainingEvents =
            if List.member m noTrainingMonths then
                []

            else
                trainings
                    |> List.filter (\t -> t.dow == dowOf k && (model.coach == "" || t.coach == model.coach))
                    |> List.sortBy .start
                    |> List.map TrainingEv
    in
    campEvents ++ trainingEvents



-- VAADE


view : Model -> Html Msg
view model =
    div []
        [ viewHeader
        , main_ []
            [ viewHero
            , viewSchedule model
            , viewSeasons model
            , viewCamps
            , viewCalendar model
            , viewTeam
            , viewLogin
            ]
        , footer [] [ div [ class "wrap" ] [ text "© 2026 Spordivaim · Klubi juht Meelis · Peatreener Annika" ] ]
        ]


viewHeader : Html Msg
viewHeader =
    header [ class "top" ]
        [ div [ class "wrap bar" ]
            [ a [ class "logo", href "#top" ] [ span [] [ text "SV" ], text " Spordivaim" ]
            , nav [ attribute "aria-label" "Peamenüü" ]
                [ a [ href "#ajakava" ] [ text "Ajakava" ]
                , a [ href "#hooajad" ] [ text "Hooajad" ]
                , a [ href "#laagrid" ] [ text "Laagrid" ]
                , a [ href "#kalender" ] [ text "Treenerite kalender" ]
                ]
            , button [ class "btn", disabled True, title "Gmaili sisselogimine lisandub hiljem" ] [ text "Logi sisse" ]
            ]
        ]


viewHero : Html Msg
viewHero =
    div [ class "wrap hero", id "top" ]
        [ h1 [] [ text "Liikumisrõõm 1.–4. klassini" ]
        , p [] [ text "Spordiklubi algklassilastele. Trennid toimuvad klassi järgi gruppides ning spordialad vahelduvad hooaegade kaupa." ]
        , div [ class "chips" ]
            (groups
                |> List.map (\g -> span [ class "gchip" ] [ i [ class ("dot " ++ g.cls) ] [], text g.name ])
            )
        ]


section_ : String -> String -> String -> List (Html Msg) -> Html Msg
section_ sid heading lead content =
    section [ id sid ]
        [ div [ class "wrap" ]
            ([ h2 [] [ text heading ] ]
                ++ (if lead == "" then
                        []

                    else
                        [ p [ class "lead" ] [ text lead ] ]
                   )
                ++ content
            )
        ]


viewSchedule : Model -> Html Msg
viewSchedule model =
    let
        tab gid txt cls =
            button
                [ class "tab"
                , attribute "aria-pressed"
                    (if model.group == gid then
                        "true"

                     else
                        "false"
                    )
                , onClick (SelectGroup gid)
                ]
                (if gid == 0 then
                    [ text txt ]

                 else
                    [ i [ class ("dot " ++ cls) ] [], text txt ]
                )

        tabs =
            tab 0 "Kõik klassid" ""
                :: List.map (\g -> tab g.id g.name g.cls) groups

        dayBox idx name =
            let
                list =
                    trainings
                        |> List.filter (\t -> t.dow == idx && (model.group == 0 || t.group == model.group))
                        |> List.sortBy .start
            in
            div [ class "day" ]
                [ h3 [] [ text name ]
                , if List.isEmpty list then
                    p [ class "empty" ] [ text "Trenni pole" ]

                  else
                    div [] (List.map slot list)
                ]

        slot t =
            let
                g =
                    groupById t.group
            in
            div [ class ("slot " ++ g.cls) ]
                [ b [] [ text (t.start ++ "–" ++ t.end) ]
                , text t.sport
                , small [] [ text (g.name ++ " · " ++ t.coach ++ " · " ++ t.place) ]
                ]
    in
    section_ "ajakava"
        "Trennide ajakava"
        "Trennid toimuvad kell 16:00–19:00, 1. klassi trenn kestab 1 h 15 min. Suvevaheajal trenne ei toimu."
        [ div [ class "tabs", attribute "role" "group", attribute "aria-label" "Vali klass" ] tabs
        , div [ class "days" ] (List.indexedMap dayBox dayNames)
        ]


viewSeasons : Model -> Html Msg
viewSeasons model =
    let
        ( _, nowMonth, _ ) =
            fromKey model.today

        card s =
            let
                isNow =
                    List.member nowMonth s.months
            in
            article
                [ class
                    ("season"
                        ++ (if isNow then
                                " now"

                            else
                                ""
                           )
                    )
                ]
                [ div [ class ("hd " ++ s.cls) ]
                    [ h3 []
                        ([ text s.name ]
                            ++ (if isNow then
                                    [ span [ class "now-tag" ] [ text "Praegu" ] ]

                                else
                                    []
                               )
                        )
                    , span [] [ text s.range ]
                    ]
                , ul [] (List.map (\x -> li [] [ text x ]) s.sports)
                ]
    in
    section_ "hooajad"
        "Hooajad ja spordialad"
        "Igal hooajal on oma teema. Praegune hooaeg on esile tõstetud."
        [ div [ class "seasons" ] (List.map card seasons) ]


viewCamps : Html Msg
viewCamps =
    let
        card c =
            article [ class "camp" ]
                [ h3 [] [ text c.name ]
                , div [ class "when" ] [ text (dateLabel c.start ++ " – " ++ dateLabel c.end) ]
                , p [ style "margin" "0" ] [ text c.desc ]
                , small [ class "muted" ] [ text c.place ]
                , button [ class "btn", disabled True ] [ text "Registreerimine avaneb peagi" ]
                ]
    in
    section_ "laagrid"
        "Laagrid"
        "Koolivaheaegade laagrid kõigile neljale klassile."
        [ div [ class "camps" ] (List.map card camps) ]


viewCalendar : Model -> Html Msg
viewCalendar model =
    let
        coachOptions =
            option [ value "", selected (model.coach == "") ] [ text "Kõik treenerid" ]
                :: List.map (\c -> option [ value c, selected (model.coach == c) ] [ text c ]) coaches

        head =
            div [ class "cal-head" ]
                [ button [ class "btn", onClick PrevMonth, attribute "aria-label" "Eelmine kuu" ] [ text "‹" ]
                , h3 [] [ text (nth (model.viewMonth - 1) monthNames ++ " " ++ String.fromInt model.viewYear) ]
                , button [ class "btn", onClick NextMonth, attribute "aria-label" "Järgmine kuu" ] [ text "›" ]
                , button [ class "btn", onClick GoToday ] [ text "Täna" ]
                , label [] [ text "Treener ", select [ onInput SelectCoach ] coachOptions ]
                ]

        dim =
            daysInMonth model.viewYear model.viewMonth

        offset =
            dowOf (toKey model.viewYear model.viewMonth 1)

        total =
            ceiling (toFloat (offset + dim) / 7) * 7

        cellFor idx =
            let
                day =
                    idx - offset + 1
            in
            if day < 1 || day > dim then
                div [ class "cell out" ] []

            else
                viewCell model (toKey model.viewYear model.viewMonth day) day
    in
    section_ "kalender"
        "Treenerite kalender"
        "Kõik trennid ja laagrid ühes kuuvaates. Vali treener, et näha ainult tema päevi."
        [ head
        , div [ class "cal-scroll" ]
            [ div [ class "cal" ]
                (List.map (\d -> div [ class "dow" ] [ text d ]) shortDays
                    ++ List.map cellFor (List.range 0 (total - 1))
                )
            ]
        , viewDetail model
        ]


viewCell : Model -> Int -> Int -> Html Msg
viewCell model k day =
    let
        evs =
            eventsOn model k

        chip e =
            case e of
                CampEv c ->
                    span [ class "ev camp" ] [ text c.name ]

                TrainingEv t ->
                    span [ class ("ev " ++ (groupById t.group).cls) ]
                        [ text (t.start ++ " " ++ (groupById t.group).name) ]

        cls =
            "cell"
                ++ (if k == model.today then
                        " today"

                    else
                        ""
                   )
                ++ (if k == model.selected then
                        " sel"

                    else
                        ""
                   )
    in
    button [ class cls, onClick (SelectDay k) ]
        ([ span [ class "n" ] [ text (String.fromInt day) ] ]
            ++ List.map chip (List.take 3 evs)
            ++ (if List.length evs > 3 then
                    [ span [ class "empty" ] [ text ("+" ++ String.fromInt (List.length evs - 3)) ] ]

                else
                    []
               )
        )


viewDetail : Model -> Html Msg
viewDetail model =
    if model.selected == 0 then
        div [ class "detail" ] []

    else
        let
            ( _, m, d ) =
                fromKey model.selected

            evs =
                eventsOn model model.selected

            item e =
                case e of
                    CampEv c ->
                        li [] [ b [] [ text c.name ], text (" – " ++ c.desc ++ " (" ++ c.place ++ ")") ]

                    TrainingEv t ->
                        li []
                            [ b [] [ text (t.start ++ "–" ++ t.end) ]
                            , text (" " ++ t.sport ++ ", " ++ (groupById t.group).name ++ ". Treener " ++ t.coach ++ ", " ++ t.place)
                            ]
        in
        div [ class "detail", attribute "aria-live" "polite" ]
            [ h3 [] [ text (nth (dowOf model.selected) dayNames ++ ", " ++ String.fromInt d ++ ". " ++ nth (m - 1) monthNames) ]
            , if List.isEmpty evs then
                p [ class "empty" ] [ text "Sellel päeval pole trenne ega laagreid." ]

              else
                ul [] (List.map item evs)
            ]


viewTeam : Html Msg
viewTeam =
    section_ "meeskond"
        "Meeskond"
        ""
        [ div [ class "camps" ]
            [ article [ class "camp" ] [ h3 [] [ text "Meelis" ], div [ class "when" ] [ text "Spordivaimu juht" ] ]
            , article [ class "camp" ] [ h3 [] [ text "Annika" ], div [ class "when" ] [ text "Peatreener" ] ]
            ]
        ]


viewLogin : Html Msg
viewLogin =
    section [ id "login" ]
        [ div [ class "wrap" ]
            [ div [ class "login" ]
                [ div []
                    [ h3 [] [ text "Treeneritele ja lapsevanematele" ]
                    , p [ class "muted", style "margin" "6px 0 0" ] [ text "Sisselogimine Google’i kontoga lisandub peagi." ]
                    ]
                , button [ class "btn pri", disabled True ] [ text "Logi sisse Gmailiga" ]
                ]
            ]
        ]



-- PEAMINE


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
