# Tizbin Design System

Bright, playful, extremely simple mobile puzzle game for a Persian-speaking audience of all ages (children to grandparents). Light theme. Full Persian right-to-left (RTL) interface: text is right-aligned, back arrows point right, the first tab sits on the right.

## Color (use ONLY these colors; no default violet or indigo, no flat neutral grey)
- Background: #F4FCF4 (tinted near-white)
- Surface (cards, sheets, game tiles): #FFFFFF; Surface alt (grouped rows): #E8F5E8
- Accent (bright, large fills, icons, active states, big numerals): #107C10
- Accent fill (any button or chip with a WHITE label, links): #0F770F; pressed #0E6D0E
- Accent tint (selected states, chip fills): #DDF0DD
- Support (decoration, card backs, illustration accents): #CDB4FF; support strong (chart second series, icons): #A978FF
- Text primary #0C1F0C, secondary #455745, tertiary #5C705C
- Hairline divider #D3E4D3; input and control borders #6DA06D
- Status (text on tint): success #0E7C3A on #E3F4E9, warning #A75906 on #FAEFE1, danger #CE2020 on #FBE5E5, info #0F770F on #E2EFE2
- Hero gradient (any surface carrying white text): #0F770F -> #0E6D0E. The soft accent -> support blend (#107C10 -> #CDB4FF) is decoration only, never behind text.
- Game objects (flat 2D vector art inside tiles) may use a cheerful set: apple red #E5484D, banana yellow #F5C518, sky blue #3B9EFF, orange #FF8A3D, plus accent green and support lavender.

## Typography
- Family: Vazirmatn for ALL text (Persian script), including numerals. Use Persian digits.
- Display 32 / 800 (screen titles, hero numbers, timer)
- Title 20 / 700 (section headers, card titles, game prompts)
- Body 16 / 400
- Label 14 / 600 (buttons, tabs)
- Caption 13 / 500 (metadata, secondary color)
- Use only these 5 sizes. Minimum text 12px (13px chips and tags, 14px legal text).

## Frame and layout
- 393x852 mobile frame, RTL. Keep top ~59px (status bar) and bottom ~34px (home indicator) clear of tappable content.
- 8pt spacing (4, 8, 12, 16, 24, 32), screen edge padding 20px, generous vertical rhythm.
- Radius: card 20, control 14, input 12, game tile 16, pill 999.
- Elevation: soft only, card = 0 1px 2px rgba(12,31,12,.04) + 0 8px 24px rgba(12,31,12,.06). No hard or black shadows.
- Icons: one set only, Lucide-style rounded outline, 24px, 1.75 stroke. Do not mix filled and outline.

## Controls (one spec each, reused on every screen)
- Primary button: pill, 56px tall, fill #0F770F, white 14/600 label; pressed #0E6D0E; disabled 40% opacity.
- Secondary button: pill, white fill, 1.5px #6DA06D border, ink label.
- Text input: 12px radius, 52px tall, white, 1px #6DA06D border, right-aligned text; focus = 2px #0F770F ring; error = #CE2020 border + 13px helper.
- Card: white, 20px radius, soft shadow.
- Chip: pill, 32px tall, #DDF0DD fill, #0F770F 13px label. Chips on a gradient use a dark translucent fill with white text, never white fill.
- Game tile: 16px radius white card, 1.5px #D3E4D3 border, one big flat 2D object centered; correct = #E3F4E9 fill + #0E7C3A check; wrong = #FBE5E5 fill + #CE2020 x. Answer buttons are big (at least 64px tall) so a child or an elderly person can tap them.
- Progress bar: 8px pill track #E8F5E8, fill #107C10.

## Shared components
- Bottom tab bar (exactly 4 tabs). In RTL order from RIGHT to LEFT: Home "خانه" (home icon), Ranks "رتبه‌ها" (trophy icon), History "تاریخچه" (clock icon), Profile "پروفایل" (user icon). Flat white bar, 1px #D3E4D3 top border, no gradient. Active tab: icon + label in #0F770F with a small #DDF0DD pill behind the icon. Inactive: #455745. Never rename, reorder, add or remove tabs.
- Header (tab screens): title or greeting on the right in Display style; points chip on the left (star icon + points, #DDF0DD fill, #0F770F text).
- Game header (all 5 game screens, full-screen, no tab bar): challenge counter "۳ از ۱۵" on the right, round countdown timer ring in the center (seconds left of 90, accent ring on #E8F5E8 track), score chip on the left; a 15-segment progress bar below.

## Focal element
One bold focal element per screen (start-game hero card, the game board, big score numeral, podium). Everything else stays quiet.

## Imagery
Real photography only for people, avatars, onboarding and empty states. Game pieces are flat 2D vector objects (fruit, animals, shapes, houses) with no shading. NO 3D renders, claymorphism, isometric, CGI or glossy plastic objects.

## Meaning of color
Red only for wrong answers, errors and destructive actions. Warnings (suspicious score flags) use the warning color with an icon.

## Copy scope
All UI copy in Persian. Do not mention: withdraw, wallet, deposit, bet, gambling, crypto, subscription, premium, in-app purchase. No invented integrations. People names only: سارا احمدی، رضا کریمی، مریم حسینی، علی رضایی، نیما صادقی، لیلا موسوی، امیر جعفری، زهرا کاظمی.
