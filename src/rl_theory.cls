\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{src/rl_theory}

\ProcessOptions\relax

\LoadClass[a4paper]{report}  

\makeatletter
\newcommand\mynobreakpar{\par\nobreak\@afterheading} 
\makeatother

\newcommand{\tsectionfmt}[3]{#1{\bf #2.\nobreak}#3\mynobreakpar}
\renewenvironment{part}[1]{\tsectionfmt{\underline}{#1}{}}{}

\RequirePackage{soul}
\RequirePackage{mathtools}
\RequirePackage{amsmath}
\RequirePackage{amsfonts}
\RequirePackage{xcolor}
\RequirePackage{tikz}
\RequirePackage{calc}
\RequirePackage{xintexpr}
\RequirePackage[many]{tcolorbox}
\RequirePackage{parskip}
\RequirePackage{fullpage}
\RequirePackage{suffix}
\RequirePackage[pdftex, pdfborderstyle={/S/U/W 0}]{hyperref}
\RequirePackage{catchfile}
\RequirePackage{xifthen}
\RequirePackage[top=0.5in, bottom=0.7in, left=1in, right=1in, includeheadfoot, headsep=20pt]{geometry}
\setlength{\headheight}{15pt}

\usetikzlibrary{calc}
% --- general notation ---
\newcommand{\listgen}[3]{\ensuremath{#1_#2, \ldots, #1_{#3}}}
\newcommand{\listof}[2]{\listgen{#1}{1}{#2}}
\newcommand{\listn}[1]{\listof{#1}{n}}

\def\P{{\rm Pr}}
\def\R{\mathbb R}
\def\E{\mathbb E}

\DeclareMathOperator*{\argmax}{arg\,max}
\DeclareMathOperator*{\argmin}{arg\,min}

\def\noteop #1 #2{\stackrel{\text{(#1)}}{#2}}
\def\edots#1#2#3{#1_{#2},\ldots,#1_{#3}}

\def\todo{\hskip 0pt {\color{gray}{[TODO]}}}
\def\mtodo{\text{\todo}}

\def\fnnot#1#2#3{#1 : #2 \rightarrow #3}

\def\ctext#1{$$\text{#1}$$}
% ---

\newif\iffull
\fullfalse

% --- colors ---
\definecolor{___gray}{rgb}{0.95, 0.95, 0.95}
\definecolor{__gray}{rgb}{0.85, 0.85, 0.85}
\definecolor{_gray}{rgb}{0.70, 0.70, 0.70}
\definecolor{gray}{rgb}{0.50, 0.50, 0.50}
\definecolor{blue}{rgb}{0.56, 0.74, 0.86}
\definecolor{red}{rgb}{1, 0.51, 0.56}
\definecolor{green}{rgb}{0.53, 0.66, 0.42}

\def\hlg#1{\hlc[___gray]{#1}}

\newcommand{\hlc}[2][yellow]{{%
  \colorlet{tempcolor}{#1}%
  \sethlcolor{tempcolor}\hl{#2}}%
}
% ---

% --- command processing ---
\def\runcmd#1{\immediate\write18{#1}}

\def\readcmd#1#2{%
  \CatchFileDef{\cftemp}{|"#1"}{}%
  \expandafter\def\expandafter#2\expandafter{\expandafter\stripspace\cftemp\next}%
}%

\def\stripspace#1 \next{#1}
\edef\root{src}
% ---

% --- linking ---
\def\ln#1#2{%
  \iffull%
  \hyperref[#1]{#2}%
  \else%
  \href{#1}{#2}%
  \fi%
}

% specially formatted link 
\newcommand\lnfmt[4][]{%
  \def\templntext{\fmtln[#1]{#3}{#4}}%
  \ln{#2}{\templntext}%
}

% "local" reference link
\newcommand\lnl[5][]{%
	\iffull%
		\def\temppath{\currreference/#4/#2}%
		\Ifinlist{\temppath}{\firstreflist}{%
		}{%
			\labeltext{\temppath_}%
			\edef\firstreflist{\firstreflist,\temppath}%
		}%
		\lnfmt[#1]{\temppath}{#3}{#5}%
	\else%
		\lnfmt[#1]{#4/#2/ref.pdf}{#3}{#5}%
	\fi%
}

% "global" reference link
\newcommand\lng[4][]{%
  \iffull\def\temp{#2}\else\getrelpathln{#2}{\temp}\fi%
  \lnfmt[#1]{\temp}{#3}{#4}%
}

\newcommand\lnproof[3][]{\lnl[#1]{#2}{#3}{proof}{P}}
\newcommand\lnnote[3][]{\lnl[#1]{#2}{#3}{note}{N}}
\newcommand\lngproof[3][]{\lng[#1]{#2}{#3}{P}}
\newcommand\lngnote[3][]{\lng[#1]{#2}{#3}{N}}

\newcommand\fmtln[3][]{%
  \ifthenelse{\equal{#1}{}}%
  {%
    $\color{blue}[$\color{black}#2$\color{blue}]_{\rm{}#3}$%
  }%
  {%
    $\color{blue}\left[\text{\color{black}#2}\color{blue}\right]\!_{\rm{}#3}$%
  }%
}

\def\firstreflist{}

\makeatletter
\newcommand{\labeltext}[1]{%
  \@bsphack
  \csname phantomsection\endcsname % in case hyperref is used
  \def\@currentlabel{#1}{\label{#1}}%
  \@esphack
}
\makeatother

\MakeRobust{\ref}% avoid expanding it when in a textual label
% ---

% --- references ---
\def\includereference#1{
  \begin{reference}{#1}
    \input{\curr/ref.tex}
  \end{reference}
}

\newenvironment{reference}[1]
{
  \def\currreference{#1}
  \newpage
  \iffull
    \labeltext{#1}
  \fi
  \def\curr{\root/#1}
  \gdef\currpath{\pathfmt{#1}}
  %\setcounter{page}{1}
  \pagestyle{fancy}
  \fancyhead[R]{\currpath}
  \inheritdefs
}
{
}
% ---

% --- reference path formatting ---
\def\getrelpathln#1#2{\readcmd{python \root/scripts/relpathln.py "\curr" "\root/#1"}{#2}}

\def\proofd{{\color{blue!80!black}P}}
\def\noted{{\color{blue!80!black}N}}

\def\pathfmt#1{\readcmd{python \root/scripts/path_fmt.py "#1" "\iffull F\else N\fi"}{\temp}\colorbox{__gray}{\temp}}
% ---

% --- boxes ---
\newenvironment{mytcb}[1][]
{
  \begin{tcolorbox}[breakable, #1]
  \parskip=10pt
}
{
  \end{tcolorbox}
}

\newenvironment{proposition}[1][Proposition \currpath.]
{
  \begin{mytcb}[title={#1}, 
    colback=blue!5, colbacktitle=blue!40, coltitle=black, colframe=blue!60!black,
    arc=0.1mm]
}
{
  \end{mytcb}
}

\newenvironment{proof}
{
    \begin{mytcb}[title={Proof.}, 
        colbacktitle=___gray, coltitle=black, colback=white, colframe=gray!80!black,
        arc=0.1mm]
}
{
    \end{mytcb}
}

\newenvironment{note}[1][Note \currpath.]
{
  \begin{mytcb}[title={#1}, 
    colback=_gray!15, colbacktitle=_gray!30, coltitle=black, colframe=_gray!60!black,
    arc=0.1mm]
}
{
  \end{mytcb}
}

% ---

% --- header ---
\RequirePackage{fancyhdr}
\pagestyle{fancy}

\renewcommand{\headrulewidth}{0pt}
% ---

\def\inheritdefs{\readcmd{\root/scripts/defs_inheritance.sh "\curr"}{\defsinherited} \defsinherited}

\def\sc{\setcounter}
\def\nc{\newcounter}
\def\defl#1#2{\expandafter\gdef\csname #1\endcsname{#2}}
\def\getl#1{\csname #1\endcsname}

\nc{a}
\nc{b}
\nc{c}
\nc{d}

\def\ifbool{\xintifboolexpr}
\def\defeq{\coloneqq}

\renewcommand{\labelitemi}{--}
\renewcommand{\labelitemii}{--}
\renewcommand{\labelitemiii}{--}
\renewcommand{\labelitemiv}{--}

\makeatletter
\newcommand*{\Ifinlist}[2]{%
  \edef\tempa{#1}%
  \edef\tempb{#2}%
  \expandafter\expandafter\expandafter\in@\expandafter\expandafter\expandafter{\expandafter\expandafter\expandafter,\expandafter\tempa\expandafter,\expandafter}\expandafter{\expandafter,\tempb,}%
  \ifin@
    \expandafter\@firstoftwo
  \else
    \expandafter\@secondoftwo
  \fi
}
\makeatother

\def\rinclude#1{\include{\curr/#1}}