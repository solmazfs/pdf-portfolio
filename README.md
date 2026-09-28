# pdf-portfolio

A minimalist static PDF portfolio generator built with Markdown, Pandoc, Lua, and LaTeX.

## Usage

```bash
./build.sh
```

## How It Works

Content is written in Markdown. A Lua filter handles layout-specific logic, while
LaTeX takes care of typography and PDF rendering.

## Dependencies

- `pandoc`
- `texlive-basic`
- `texlive-latex`
- `texlive-latexextra`
- `texlive-binextra`
- `texlive-fontsrecommended`
- `texlive-fontsextra`
- `curl` for initial placeholder images

## Configuration

Layout is defined using Pandoc Div blocks (`:::`), which are converted to LaTeX
environments by `layout.lua`.

### Intro

```markdown
::: {.intro}
Title string

Body text paragraphs.
:::
```

### Gallery

```markdown
::: {.gallery layout="row-three" placement="!b" break-after="page"}
![Alt](media/img1.jpg){width=40%}
![Alt](media/img2.jpg){width=30%}
![Alt](media/img3.jpg){width=25%}
:::
```

Supported layouts:

- `row-three`
- `staggered-three`
- `staggered-two`

The `placement` attribute accepts standard LaTeX float options such as `!h`,
`!t`, and `!b`.

### Artwork

```markdown
::: {.artwork width="80%" align="center" caption-align="center"}
![Alt](media/img.jpg)

Caption paragraph.

Additional body paragraphs.
:::
```

### Closing

```markdown
::: {.closing}
Title

Contact info

Social links
:::
```

## License

MIT License
