from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    ListFlowable,
    ListItem,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "docs" / "USER_GUIDE.zh-CN.pdf"


def register_font() -> str:
    candidates = [
        Path("C:/Windows/Fonts/msyh.ttc"),
        Path("C:/Windows/Fonts/simhei.ttf"),
        Path("C:/Windows/Fonts/simsun.ttc"),
    ]
    for font_path in candidates:
        if font_path.exists():
            pdfmetrics.registerFont(TTFont("CJK", str(font_path)))
            return "CJK"
    return "Helvetica"


FONT = register_font()


def p(text: str, style: ParagraphStyle) -> Paragraph:
    return Paragraph(text.replace("\n", "<br/>"), style)


def bullets(items, style):
    return ListFlowable(
        [ListItem(p(item, style), leftIndent=6) for item in items],
        bulletType="bullet",
        leftIndent=14,
        bulletFontName=FONT,
        bulletFontSize=9,
        bulletColor=colors.HexColor("#0f172a"),
    )


def steps(items, style):
    return ListFlowable(
        [ListItem(p(item, style), leftIndent=6) for item in items],
        bulletType="1",
        leftIndent=18,
        bulletFontName=FONT,
        bulletFontSize=9,
    )


def add_section(story, title, body=None):
    story.append(p(title, STYLES["Heading2"]))
    if body:
        story.append(p(body, STYLES["Body"]))
    story.append(Spacer(1, 5 * mm))


def header_footer(canvas, doc):
    canvas.saveState()
    canvas.setFont(FONT, 8)
    canvas.setFillColor(colors.HexColor("#64748b"))
    canvas.drawString(18 * mm, 12 * mm, "Codex Provider Switcher 使用手册")
    canvas.drawRightString(192 * mm, 12 * mm, f"第 {doc.page} 页")
    canvas.restoreState()


styles = getSampleStyleSheet()
STYLES = {
    "Title": ParagraphStyle(
        "Title",
        parent=styles["Title"],
        fontName=FONT,
        fontSize=24,
        leading=32,
        alignment=TA_CENTER,
        textColor=colors.HexColor("#0f172a"),
        spaceAfter=10 * mm,
    ),
    "Subtitle": ParagraphStyle(
        "Subtitle",
        parent=styles["Normal"],
        fontName=FONT,
        fontSize=11,
        leading=18,
        alignment=TA_CENTER,
        textColor=colors.HexColor("#475569"),
        spaceAfter=12 * mm,
    ),
    "Heading2": ParagraphStyle(
        "Heading2",
        parent=styles["Heading2"],
        fontName=FONT,
        fontSize=15,
        leading=22,
        textColor=colors.HexColor("#0f172a"),
        spaceBefore=3 * mm,
        spaceAfter=3 * mm,
    ),
    "Body": ParagraphStyle(
        "Body",
        parent=styles["BodyText"],
        fontName=FONT,
        fontSize=9.5,
        leading=16,
        textColor=colors.HexColor("#1f2937"),
        spaceAfter=3 * mm,
    ),
    "Small": ParagraphStyle(
        "Small",
        parent=styles["BodyText"],
        fontName=FONT,
        fontSize=8.5,
        leading=13,
        textColor=colors.HexColor("#334155"),
    ),
    "Code": ParagraphStyle(
        "Code",
        parent=styles["Code"],
        fontName=FONT,
        fontSize=8.3,
        leading=12,
        textColor=colors.HexColor("#0f172a"),
        backColor=colors.HexColor("#f1f5f9"),
        borderPadding=5,
        spaceAfter=4 * mm,
    ),
}


def make_table(rows, widths):
    table = Table(rows, colWidths=widths, hAlign="LEFT")
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#e2e8f0")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.HexColor("#0f172a")),
                ("FONTNAME", (0, 0), (-1, -1), FONT),
                ("FONTSIZE", (0, 0), (-1, -1), 8.6),
                ("LEADING", (0, 0), (-1, -1), 12),
                ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#cbd5e1")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#f8fafc")]),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (-1, -1), 6),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
            ]
        )
    )
    return table


def build():
    doc = SimpleDocTemplate(
        str(OUTPUT),
        pagesize=A4,
        leftMargin=18 * mm,
        rightMargin=18 * mm,
        topMargin=18 * mm,
        bottomMargin=18 * mm,
        title="Codex Provider Switcher 使用手册",
        author="Codex Provider Switcher",
    )

    story = []
    story.append(p("Codex Provider Switcher 使用手册", STYLES["Title"]))
    story.append(
        p(
            "一键切换官方 ChatGPT 账号连接和第三方 OpenAI-compatible 网关。普通用户只需要看状态、选连接、点按钮。",
            STYLES["Subtitle"],
        )
    )

    add_section(
        story,
        "1. 这个工具是做什么的",
        "它把 Codex 的连接切换做成 Windows 桌面应用。你可以在官方 ChatGPT 账号模式和第三方 API 网关模式之间切换，不需要手动改 config.toml。",
    )
    story.append(
        bullets(
            [
                "官方 ChatGPT 账号连接：使用 ChatGPT 账号里的 Codex 额度。",
                "第三方连接：使用 CCswitch/Freemodel、OpenRouter、SiliconFlow/硅基流动、私有网关等兼容服务。",
                "每次切换前都会自动备份配置，方便出错时恢复。",
            ],
            STYLES["Body"],
        )
    )
    story.append(Spacer(1, 4 * mm))

    add_section(story, "2. 推荐使用流程")
    story.append(
        steps(
            [
                "打开桌面快捷方式 Codex Provider Switcher。",
                "点击 连接状态，确认当前 Codex 使用的是官方账号还是第三方连接。",
                "要使用官方账号额度，点击 使用官方 ChatGPT。",
                "要使用第三方连接，在 第三方连接 下拉框里选择连接，再点击 使用所选第三方。",
                "列表里没有你的第三方时，点击 添加第三方连接，选择模板，填入 API Key 和模型名。",
                "切换完成后，重启已经打开的 Codex 窗口。",
            ],
            STYLES["Body"],
        )
    )

    add_section(story, "3. 安装")
    story.append(bullets(["Windows 10 或 Windows 11。", "已安装 Codex CLI，并且 codex 命令可用。", "官方模式需要 Codex 已通过 Sign in with ChatGPT 登录。"], STYLES["Body"]))
    story.append(p("在项目目录运行：", STYLES["Body"]))
    story.append(p("powershell -NoProfile -ExecutionPolicy Bypass -File .\\installer\\install.ps1", STYLES["Code"]))
    story.append(
        bullets(
            [
                "桌面快捷方式：Codex Provider Switcher。",
                "开始菜单快捷方式：Codex Provider Switcher。",
                "本地安装目录：%USERPROFILE%\\.codex\\provider-switch。",
                "第三方连接配置文件：%USERPROFILE%\\.codex\\provider-switch\\providers.json。",
            ],
            STYLES["Body"],
        )
    )

    story.append(PageBreak())
    add_section(story, "4. 主界面按钮说明")
    rows = [
        [p("按钮", STYLES["Small"]), p("作用", STYLES["Small"])],
        [p("连接状态", STYLES["Small"]), p("查看当前连接、第三方 Key 是否存在、ChatGPT 登录状态。", STYLES["Small"])],
        [p("使用官方 ChatGPT", STYLES["Small"]), p("切换到官方 OpenAI provider 和 ChatGPT 账号模式。", STYLES["Small"])],
        [p("使用所选第三方", STYLES["Small"]), p("切换到下拉框当前选中的第三方连接。", STYLES["Small"])],
        [p("添加第三方连接", STYLES["Small"]), p("用模板添加新的第三方网关，并可保存 API Key 到本机环境变量。", STYLES["Small"])],
        [p("高级编辑配置", STYLES["Small"]), p("打开 providers.json，给高级用户手动修改。", STYLES["Small"])],
        [p("刷新列表", STYLES["Small"]), p("保存配置后刷新第三方下拉框。", STYLES["Small"])],
        [p("重新登录 ChatGPT", STYLES["Small"]), p("官方模式仍显示 API Key 登录时，重新走 ChatGPT 登录流程。", STYLES["Small"])],
    ]
    story.append(make_table(rows, [48 * mm, 124 * mm]))
    story.append(Spacer(1, 6 * mm))

    add_section(story, "5. 添加第三方连接")
    story.append(
        steps(
            [
                "点击 添加第三方连接。",
                "在 连接模板 中选择 CCswitch / Freemodel、OpenRouter、SiliconFlow / 硅基流动 或 自定义。",
                "填入 API Key。Key 只保存到当前 Windows 用户环境变量，不会写进项目文件。",
                "确认 API 地址、环境变量名、模型名称、接口类型。",
                "点击 保存。",
                "回到主界面选择新连接，并点击 使用所选第三方。",
            ],
            STYLES["Body"],
        )
    )
    story.append(
        p(
            "内置模板会预填常见公开参数，但最终模型名仍要以你自己的第三方账号可用模型为准。",
            STYLES["Body"],
        )
    )
    rows = [
        [p("字段", STYLES["Small"]), p("说明", STYLES["Small"])],
        [p("API 地址", STYLES["Small"]), p("第三方网关给你的接口地址。", STYLES["Small"])],
        [p("环境变量名", STYLES["Small"]), p("保存 API Key 的变量名，例如 OPENROUTER_API_KEY。", STYLES["Small"])],
        [p("模型名称", STYLES["Small"]), p("第三方网关要求的模型名。", STYLES["Small"])],
        [p("接口类型", STYLES["Small"]), p("通常是 responses 或 chat，以第三方网关说明为准。", STYLES["Small"])],
    ]
    story.append(make_table(rows, [48 * mm, 124 * mm]))

    add_section(
        story,
        "6. 官方 ChatGPT 模式",
        "点击 使用官方 ChatGPT 后，工具会把 Codex 切换回官方 openai provider 和 ChatGPT 账号登录模式。如果状态仍显示 API Key 登录，点击 重新登录 ChatGPT，然后选择 Sign in with ChatGPT。",
    )

    add_section(
        story,
        "7. 高级配置",
        "高级用户可以手动编辑 providers.json。普通用户建议使用 添加第三方连接 表单。",
    )
    story.append(p("%USERPROFILE%\\.codex\\provider-switch\\providers.json", STYLES["Code"]))
    story.append(p("保存后回到应用，点击 刷新列表。", STYLES["Body"]))

    story.append(PageBreak())
    add_section(story, "8. 卸载")
    story.append(p("在项目目录运行：", STYLES["Body"]))
    story.append(p("powershell -NoProfile -ExecutionPolicy Bypass -File .\\installer\\uninstall.ps1", STYLES["Code"]))
    story.append(p("卸载只删除应用文件和快捷方式，不会删除：", STYLES["Body"]))
    story.append(
        bullets(
            [
                "Codex 主配置文件。",
                "Windows 环境变量。",
                "ChatGPT 登录凭据。",
                "配置备份。",
            ],
            STYLES["Body"],
        )
    )

    add_section(story, "9. 常见问题")
    faq_rows = [
        [p("问题", STYLES["Small"]), p("处理方法", STYLES["Small"])],
        [p("切换后为什么还没生效", STYLES["Small"]), p("关闭并重新打开已经运行的 Codex 窗口。", STYLES["Small"])],
        [p("API Key 要不要写进 providers.json", STYLES["Small"]), p("不要。providers.json 只保存环境变量名。", STYLES["Small"])],
        [p("第三方连接不工作", STYLES["Small"]), p("检查 API Key、模型名称、接口类型 responses/chat。", STYLES["Small"])],
        [p("官方模式是否需要 OpenAI API Key", STYLES["Small"]), p("不需要。官方模式使用 Sign in with ChatGPT。", STYLES["Small"])],
    ]
    story.append(make_table(faq_rows, [56 * mm, 116 * mm]))

    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)


if __name__ == "__main__":
    build()
