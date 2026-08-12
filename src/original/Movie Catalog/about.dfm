inherited AboutWin: TAboutWin
  Left = 694
  Top = 234
  HelpContext = 1010
  BorderStyle = bsSingle
  Caption = 'About this program'
  ClientHeight = 351
  ClientWidth = 405
  OldCreateOrder = True
  Position = poDesktopCenter
  DesignSize = (
    405
    351)
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 318
    Width = 399
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 335
    Width = 405
  end
  object LLinks: TAntJvLinkLabel [2]
    Left = 5
    Top = 287
    Width = 395
    Height = 13
    Caption = 
      'E-mail: <link>amc-contact@antp.be</link>                   Site:' +
      ' <link>www.antp.be</link>'#13#10
    Text.Strings = (
      
        'E-mail: <link>amc-contact@antp.be</link>                   Site:' +
        ' <link>www.antp.be</link>'#13#10)
    Anchors = [akLeft, akRight, akBottom]
    Transparent = True
    LinkColor = clBlue
    LinkColorClicked = clBlue
    LinkColorHot = clBlue
    LinkStyle = [fsUnderline]
    HotLinks = False
    AutoHeight = False
    MarginWidth = 0
    MarginHeight = 0
    OnLinkClick = LLinksLinkClick
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Shell Dlg'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
  end
  object AntJvLinkLabel1: TAntJvLinkLabel [3]
    Left = 5
    Top = 303
    Width = 395
    Height = 13
    Caption = 
      'E-mail: <link>mickael.vanneufville@gmail.com</link>   Site: <lin' +
      'k>mickaelvanneufville.online.fr/AMCU</link>'
    Text.Strings = (
      
        'E-mail: <link>mickael.vanneufville@gmail.com</link>   Site: <lin' +
        'k>mickaelvanneufville.online.fr/AMCU</link>')
    Anchors = [akLeft, akRight, akBottom]
    Transparent = True
    LinkColor = clBlue
    LinkColorClicked = clBlue
    LinkColorHot = clBlue
    LinkStyle = [fsUnderline]
    HotLinks = False
    AutoHeight = False
    MarginWidth = 0
    MarginHeight = 0
    OnLinkClick = LLinksLinkClick
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Shell Dlg'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
  end
  inherited btn1: TCorelButton
    Left = 327
    Top = 323
    Caption = '&Credits...'
    TabOrder = 5
    Visible = True
    OnClick = btn1Click
  end
  inherited btn2: TCorelButton
    Left = 249
    Top = 323
    Caption = '&Versions...'
    TabOrder = 4
    Visible = True
    OnClick = btn2Click
  end
  inherited btn3: TCorelButton
    Left = 171
    Top = 323
    Cancel = True
    Caption = 'Close'
    Default = True
    ModalResult = 1
    TabOrder = 3
    Visible = True
  end
  inherited btn4: TCorelButton
    Left = 93
    Top = 323
    TabOrder = 2
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 405
    Height = 49
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      405
      49)
    object Shape1: TShape
      Left = 1
      Top = 1
      Width = 403
      Height = 47
      Align = alClient
      Pen.Style = psClear
    end
    object Image1: TImage
      Left = 8
      Top = 8
      Width = 32
      Height = 32
      AutoSize = True
      Center = True
      Picture.Data = {
        055449636F6E0000010002002020000001000800A80800002600000010100000
        0100080068050000CE0800002800000020000000400000000100080000000000
        0004000000000000000000000001000000000000000000000000800000800000
        008080008000000080008000808000008080800004040400E4848400CC646400
        FCFCFC00F4949400D4747400F48C8C00E47C7C00EC8C8C00CC6C6C00FC9C9C00
        DC7C7C0074040400EC848400FC949400DC747400D46C6C004C544C00C4FCFC00
        F4FCFC006C6C6C00B4FCFC000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000C0C0C0000000FF0000FF0000
        00FFFF00FF000000FF00FF00FFFF0000FFFFFF0008080808080808111818180D
        180D170D17171713170F130F0F0808080808080808080B0B0B08080A11111818
        1818180D1717171713170F0F1308080B0B0B080808080B0B0B08080A0A181118
        18180D18170D1717171713170F08080B0B0B080808080B0B0B08080808080808
        0808080808080808080808080808080B0B0B0808080808080808080808080808
        080808080808080808080808080808080808080808080808080808151510150E
        100E0E0E0E0C0E160C161616120808080808080808080B0B0B08081515100E15
        0E0E0E0C0E160C16161616121608080B0B0B080808080B0B0B0808151515150E
        10100E0E0E0E0E0E0C0C16161608080B0B0B080808080B0B0B08080915101510
        150E100E0E0C0E160C160C161608080B0B0B0808080808080808080915151515
        10150E100E0E0E0E0E0E0C160C08080808080808080808080808080F09151515
        151510150E100E0E0C0E160E160808080808080808080B0B0B0808150F090915
        151510150E100E0E0E0E0E0C0E08080B0B0B080808080B0B0B08080F0F0F1509
        1515151510150E100E0E0C0E1608080B0B0B080808080B0B0B08080F090F150F
        09151515150E15100E0E0E0E0E08080B0B0B080808080808080808130F0F0F09
        15091515151510150E100E0E0E0808080808080808080808080808170F0F0F0F
        0F0F1509151515151015100E100808080808080808080B0B0B080817130F0F0F
        090F090915091510150E150E1008080B0B0B080808080B0B0B0808171317130F
        0F0F0F150F091515151510151508080B0B0B080808080B0B0B08081717130F13
        0F0F0F0F09150915151515101508080B0B0B0808080808080808081717171717
        0F130F0F0F0F0F15091515151508080808080808080808080808080D17171713
        170F0F0F0F090F090F151515150808080808080808080B0B0B0808180D171717
        131713130F0F0F150F0909150908080B0B0B080808080B0B0B080818170D1717
        171713170F130F0F0F150F150908080B0B0B080808080B0B0B0808181818170D
        171717170F130F0F0F0F09090F08080B0B0B08080808080808080818180D1817
        0D17171317170F130F0F0F0F1508080808080808080808080808081118181818
        170D17171713170F130F090F0F0808080808080808080B0B0B0808111818180D
        180D170D17171713170F130F0F08080B0B0B080808080B0B0B08080A11111818
        1818180D1717171713170F0F1308080B0B0B080808080B0B0B08080A0A181118
        18180D18170D1717171713170F08080B0B0B0808080808080808080808080808
        0808080808080808080808080808080808080808080808080808080808080808
        080808080808080808080808080808080808080808080B0B0B0808151510150E
        100E0E0E0E0C0E160C1616161208080B0B0B0808000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000280000001000000020000000
        0100080000000000000100000000000000000000000100000000000000000000
        000080000080000000808000800000008000800080800000C0C0C000C0DCC000
        F0CAA600D4F0FF00B1E2FF008ED4FF006BC6FF0048B8FF0025AAFF0000AAFF00
        0092DC00007AB90000629600004A730000325000D4E3FF00B1C7FF008EABFF00
        6B8FFF004873FF002557FF000055FF000049DC00003DB9000031960000257300
        00195000D4D4FF00B1B1FF008E8EFF006B6BFF004848FF002525FF000000FE00
        0000DC000000B900000096000000730000005000E3D4FF00C7B1FF00AB8EFF00
        8F6BFF007348FF005725FF005500FF004900DC003D00B9003100960025007300
        19005000F0D4FF00E2B1FF00D48EFF00C66BFF00B848FF00AA25FF00AA00FF00
        9200DC007A00B900620096004A00730032005000FFD4FF00FFB1FF00FF8EFF00
        FF6BFF00FF48FF00FF25FF00FE00FE00DC00DC00B900B9009600960073007300
        50005000FFD4F000FFB1E200FF8ED400FF6BC600FF48B800FF25AA00FF00AA00
        DC009200B9007A009600620073004A0050003200FFD4E300FFB1C700FF8EAB00
        FF6B8F00FF487300FF255700FF005500DC004900B9003D009600310073002500
        50001900FFD4D400FFB1B100FF8E8E00FF6B6B00FF484800FF252500FE000000
        DC000000B9000000960000007300000050000000FFE3D400FFC7B100FFAB8E00
        FF8F6B00FF734800FF572500FF550000DC490000B93D00009631000073250000
        50190000FFF0D400FFE2B100FFD48E00FFC66B00FFB84800FFAA2500FFAA0000
        DC920000B97A000096620000734A000050320000FFFFD400FFFFB100FFFF8E00
        FFFF6B00FFFF4800FFFF2500FEFE0000DCDC0000B9B900009696000073730000
        50500000F0FFD400E2FFB100D4FF8E00C6FF6B00B8FF4800AAFF2500AAFF0000
        92DC00007AB90000629600004A73000032500000E3FFD400C7FFB100ABFF8E00
        8FFF6B0073FF480057FF250055FF000049DC00003DB900003196000025730000
        19500000D4FFD400B1FFB1008EFF8E006BFF6B0048FF480025FF250000FE0000
        00DC000000B90000009600000073000000500000D4FFE300B1FFC7008EFFAB00
        6BFF8F0048FF730025FF570000FF550000DC490000B93D000096310000732500
        00501900D4FFF000B1FFE2008EFFD4006BFFC60048FFB80025FFAA0000FFAA00
        00DC920000B97A000096620000734A0000503200D4FFFF00B1FFFF008EFFFF00
        6BFFFF0048FFFF0025FFFF0000FEFE0000DCDC0000B9B9000096960000737300
        00505000F2F2F200E6E6E600DADADA00CECECE00C2C2C200B6B6B600AAAAAA00
        9E9E9E0092929200868686007A7A7A006E6E6E0062626200565656004A4A4A00
        3E3E3E0032323200262626001A1A1A000E0E0E00F0FBFF00A4A0A00080808000
        0000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0000F8F1F1
        6D6D6D6D6D6D6D61F1F1F80000FFF8F3F1F1F1F1F1F1F1F1F3F8FF00000000F3
        F0F0F0F0F0F0EFEFF300000000FFF8F06C6C6C6C6C6C6C6CEFF8FF0000F8F1F0
        6C6C6C6C6C6C6C6CEFF1F80000F8F1F16C6C6C6C6C6C6C6CF0F1F80000FFF8F1
        616C6C6C6C6C6C6CF0F8FF00000000F161616C6C6C6C6C6CF000000000FFF8F1
        6161616C6C6C6C6CF0F8FF0000F8F1F16D6D61616C6C6C6CF0F1F80000F8F1F1
        6D6D6D61616C6C6CF0F1F80000FFF8F16D6D6D6D6161616CF1F8FF00000000F1
        6D6D6D6D6D616161F100000000FFF8F16D6D6D6D6D6D6D61F1F8FF0000F8F1F3
        F1F1F1F1F1F1F1F1F3F1F800000000000000000000000000000000000000FFFF
        0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
        0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF}
    end
    object LTitle: TLabel
      Left = 48
      Top = 7
      Width = 172
      Height = 23
      Caption = 'Ant Movie Catalog'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Arial'
      Font.Style = [fsBold, fsItalic]
      ParentFont = False
      Transparent = True
    end
    object LVersion: TLabel
      Left = 48
      Top = 30
      Width = 346
      Height = 14
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = '[version]'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
  end
  object PanelScroll: TPanel
    Left = 0
    Top = 50
    Width = 405
    Height = 236
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvLowered
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Shell Dlg'
    Font.Style = []
    ParentBackground = False
    ParentColor = True
    ParentFont = False
    TabOrder = 1
    object Scroll: TAntJvScrollText
      Left = 1
      Top = 1
      Width = 403
      Height = 234
      Cursor = crSizeNS
      TextAlignment = taCenter
      Items.Strings = (
        'Ant Movie Catalog'
        'Copyright '#169' 2000-2023'
        'Antoine Potten, Mickael Vanneufville'
        ''
        ''
        #183#183#183
        ''
        ''
        'This program was made with Borland Delphi 7'
        ''
        ''
        #183#183#183
        ''
        ''
        'It also uses the following additionnal components :'
        ''
        'Innerfuse Pascal Script'
        'Toolbar2000'
        'TBX'
        'Innerfuse Pascal Script'
        'TPNGImage'
        'SynEdit'
        'ElTree'
        'FreeReport'
        'JVCL'
        'CorelButton'
        'MyLittleBase (for importation plugin)'
        'MediaInfo (as external DLL)'
        'HTML Viewer Components'
        'rkSmartView'
        'RegExpr by Andrey V. Sorokin '
        ''
        ''
        #183#183#183
        ''
        ''
        'Icon themes come from'
        'Scrows'#39' Icons, Gnome Project'
        'and Everaldo Coelho (KDE'#39's Crystal theme)'
        ''
        ''
        #183#183#183
        ''
        ''
        'I want to thank the following people that'
        'helped me on the beginning of this project:'
        ''
        ''
        'Sebastien Buysse'
        '(that'#39's him that made this nice scrolling text control!'
        'He also helps me often when I have questions about'
        'Delphi programming)'
        ''
        ''
        'Yves '#39'Robripper'#39' Robert'
        '(I started this project with him, and he sent lots of'
        'suggestions/comments)'
        ''
        ''
        'Gregory Zicot'
        '(he found lots of bugs)'
        ''
        ''
        'Brolin '#39'SneakyFungus'#39
        '(when I need a suggestion about english grammar or'
        'vocabulary, I ask him)'
        ''
        ''
        #39'Justeleblanc'#39
        '(he made the logo displayed at startup. I like this logo,'
        'but I know that some people do not really like it,'
        'I do not care)'
        ''
        ''
        'Danny Falkov'
        ''
        ''
        #39'Darkcristal'#39
        ''
        ''
        #39'PinterPeti'#39
        '(he helped me for the new CSV import engine)'
        ''
        ''
        'bad4u'
        '(very active script maker on the forum,'
        'also started to modify program code for a game catalog,'
        'and made some code for AMC to import CGstar catalog)'
        ''
        ''
        'Mickael Vanneufville'
        'a.k.a. soulsnake'
        '(he made all versions between 3.5.1 and 4.2.2, '
        'with a lot of new features)'
        ''
        ''
        '...'
        ''
        ''
        'A special thanks to the following sites,'
        'because they provided an easier access to'
        'their database for this program:'
        ''
        ''
        'DVDFR (www.dvdfr.com)'
        ''
        'Culturalia (www.culturalianet.com)'
        ''
        'BDFCI (www.bdfci.info)'
        ''
        '...'
        ''
        ''
        'I also thank the following users from my'
        'forum, that contributed a lot to the program'
        'by creating and/or updating scripts:'
        ''
        'ScorEpioN'
        'Dmitry501'
        'scorpion7552'
        'Pivello'
        'KaraGarga'
        'ABNormal'
        'O Guardi'#227'o'
        'micmic'
        'draco31.fr'
        'KaraGarga'
        'Raoul_Volfoni'
        'legrad'
        'fulvio53s03'
        'baffab'
        'J'
        'Ariell'
        'Dedej'
        ''
        ''
        'And also these users who made templates '
        'or were just being active on the forum:'
        ''
        'Willspo'
        'Twink'
        'Free51'
        'mjs7231 ('#39'PK'#39')'
        'Snille'
        'Ormus'
        'Eyael'
        'bbdoc'
        'Bad Joker'
        'folgui'
        'Ork'
        '*Guest* - Frau Holle'
        'trekkie'
        'Free51'
        'elman'
        'kazgor'
        'bonienl'
        ''
        ''
        'If you wonder where are all these templates that sound so'
        'wonderful, check the "Templates" folder of AMC,'
        'there are lots of ZIP files that contain nice things.'
        ''
        'Some newer or more complex ones are only available  from'
        'the "Templates" section of the forum (http://forum.antp.be)'
        ''
        ''
        ''
        'I am sure that I forgot people, but I am sorry, I cannot'
        'remember everybody.'
        'If you think that you should be listed here, do not hesitate'
        'to contact me ;)'
        ''
        ''
        '...'
        ''
        ''
        'And, of course, thanks to all the other users'
        'and people that sent me comments,'
        'bug reports, suggestions, etc.'
        ''
        ''
        #183#183#183
        ''
        ''
        'Translation team:'
        ''
        'Belarussian: dzmitry[li]'
        'Bulgarian: Rumen Stoyanov && Momchil Karabulev'
        'Catalan: Pau Bosch i Crespo'
        'Croatian: Josip Martincevic && Damir13'
        'Czech: Jan Kaltoun, Petr Kr'#237'z && V. Sad'#237'lek'
        'Danish: Bent M'#248'ller Madsen'
        'Dutch: J-T Fernhout, Harm Caspers, Marcel Buyle && Gino R.'
        'Estonian: com7 && Junos'
        'Finnish: Jukka-Pekka Jussila'
        'French: Antoine Potten && Micka'#235'l Vanneufville'
        'Galician: Fidi [Gz]'
        
          'German: Bad Joker, Juergen Venne, Johannes Ebner, Sven Sch'#228'fer &' +
          '& JoGeJen'
        'Greek: AllDivXGR'
        'Hebrew: Erez Ben Ari'
        'Hungarian: Kov'#225'cs Gy'#246'rgy L'#225'szl'#243' && Herczeg J'#243'zsef Tam'#225's'
        
          'Italian: Jancker, Dino Librandi, Iosa Franco && Maurizio Valsass' +
          'ina'
        'Korean: Ju Eul, Jang'
        'Latvian: Aldis B'#238'bers'
        'Lithuanian: Vytautas Ribikauskas'
        'Macedonian: Wekoslav Stefanovski'
        'Norwegian: rulle, Kai V Findahl && Frank B'
        'Polish: Adam "Adma'#39's" Malich && Bogdan Kwietniak'
        
          'Portuguese (Brazil): S'#237'lvio Faria, Filipe Guimar'#227'es, Lucas Alves' +
          ' && Fagner P.Corr'#234'a|'
        'Portuguese (Portugal): Ricardo Ribeiro && Flame'
        'Romanian: Dragos Medinschi'
        'Russian: m a x, Alexei Chehowskoi, Vitaliy Krivchikov && Stirch'
        'Serbian: Zoran "ZoNi" Nikolic, Ivan && Nemanja Bracko'
        'Slovak: Artam && Berry'
        'Slovenian: Pete Minus'
        'Spanish: Sergio Marrero Ponce'
        'Swedish: Andreas Johansson && Karin Andersson'
        'Turkish: '#214'zkan Ak && Kemal Se'#231'er'
        'Ukrainian: Maxim'
        ''
        ''
        #183#183#183
        ''
        ''
        'Boring legal stuff:'
        ''
        ''
        'This program is free software; you can redistribute it and/or'
        'modify it under the terms of the GNU General Public License'
        'as published by the Free Software Foundation; either'
        'version 2 of the License, or (at your option) any later version.'
        ''
        ''
        'This program is distributed in the hope that it will be useful,'
        'but WITHOUT ANY WARRANTY; without even the implied'
        'warranty of MERCHANTABILITY or FITNESS FOR A'
        'PARTICULAR PURPOSE. See the GNU General Public'
        'License for more details.'
        ''
        ''
        #183#183#183
        ''
        ''
        'For those that did not read the thing above: '
        ''
        'The program is free, not only in cost but also for distribution.'
        ''
        'You can distribute it, you can print its source code to cover'
        'your walls, you do what you want... as long as it is conform to'
        'the license.'
        ''
        'So before stealing the source code'
        'of the program and put it in a closed-source application,'
        'read this license and find another idea :p'
        ''
        ''
        '...'
        ''
        ''
        'You can click on "Credits" button for additionnal details,'
        'but basically I said everything here.'
        ''
        'You can find there links to special'
        'Delphi components that I used.'
        ''
        ''
        '...'
        ''
        ''
        'If you go to my site maybe you will find other nice things,'
        ''
        'Like my other program "Ant Renamer"'
        '(no, this is not an hidden ad)'
        ''
        'If like me you like cars in addition of watching movies, '
        'you may be interested in another project'
        'in which I am involved: www.imcdb.org'
        'It is about cars seen in movies'
        ''
        ''
        'You can also make donations through Paypal.'
        ''
        'If you have few hundreds of euros or dollars that you'
        'do not want to keep, I can help you.'
        ''
        'I do not make this program for money, but that'#39's not'
        'a reason to not accept money, eh?'
        ''
        'By the way, when people make donations I feel'
        'guilty for not releasing more often new versions,'
        'so it is a good way to "force" me to update the program.'
        ''
        ''
        '...'
        ''
        ''
        'You can also just stay here reading this scrolling text'
        ''
        '...'
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        'No, it is not finished yet, you can stay.'
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        'Now it is the end'
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        'He he... you can go now...'
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        'Do you also stay until the real end'
        'when you watch a movie?'
        ''
        ''
        ''
        ''
        ''
        ''
        'I often do it too.'
        'Even for the movies where there is nothing'
        'funny to read in the scrolling credits.'
        ''
        ''
        ''
        'Usually I am nearly alone in the room where the'
        'movie is _really_ finished.'
        ''
        ''
        'And sometimes there is an extra scene of 1 or 2'
        'minutes after the credits, then it is nice to have'
        'waited few minutes.'
        ''
        'And where there is nothing, well, there is less people'
        'in the stairs so I can exit faster.'
        ''
        'Well, I guess that my life is not so interesting, so I '
        'will not continue with my stories.'
        ''
        ''
        '...'
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        '...'
        ''
        'Ok, now it is the real end,'
        'I am sorry if you were expecting'
        'something special ;-)'
        ''
        #183#183#183
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        ''
        '...'
        ''
        'Well actually I lied, there is still something'
        ''
        ''
        ''
        ''
        ''
        '...'
        ''
        ''
        'Maybe I should make you wait a little more'
        ''
        ''
        'Or maybe you'#39've found that you can scroll the'
        'text by moving the move up/down while pressing'
        'the left button'
        ''
        'But that'#39's not funny, it is better to wait a little more'
        ''
        '...'
        ''
        ''
        ''
        ''
        ''
        'Do you believe there are few kilobytes (more than five)'
        'of text that are scrolling here?'
        'Yes, it is true.'
        'You'#39're lucky, there is _only_ few kilobytes and not a whole'
        'book here'
        ''
        '...'
        ''
        'For the moment, there is no more. But maybe that in the next'
        'version I will add things here, so when you upgrade you can'
        'read the whole text again (or scroll directly to the end, like'
        'I said before).'
        ''
        ''
        'Goodbye, and thanks for reading!'
        ''
        'Antoine Potten')
      Delay = 70
      BackgroundColor = clBlack
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      Align = alClient
      ShowHint = False
      ParentShowHint = False
    end
  end
  object Messages: TAntStringList
    Strings.Strings = (
      '%s : version %s (%s)'
      
        '(press Ctrl+C if you want to copy these information to clipboard' +
        ')'
      'Unable to read file information')
    Left = 16
    Top = 328
  end
end
