from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer

OUT = Path('output/pdf/Roman_Shirokov_Cover_Letter_First_Focus_Lead_Software_Engineer.pdf')
OUT.parent.mkdir(parents=True, exist_ok=True)

NAVY = colors.HexColor('#12314A')
BLUE = colors.HexColor('#176B87')
INK = colors.HexColor('#1C2730')
MUTED = colors.HexColor('#52606D')
LINE = colors.HexColor('#D9E2E8')

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='NameF', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=20, leading=24, textColor=NAVY, spaceAfter=2))
styles.add(ParagraphStyle(name='RoleF', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=10.5, leading=14, textColor=BLUE, spaceAfter=4))
styles.add(ParagraphStyle(name='ContactF', parent=styles['Normal'], fontName='Helvetica', fontSize=8.8, leading=11, textColor=MUTED, spaceAfter=13))
styles.add(ParagraphStyle(name='BodyF', parent=styles['Normal'], fontName='Helvetica', fontSize=10, leading=14.3, textColor=INK, spaceAfter=9))
styles.add(ParagraphStyle(name='DateF', parent=styles['Normal'], fontName='Helvetica', fontSize=9.5, leading=12, textColor=MUTED, spaceAfter=13))

def p(text, style='BodyF'):
    return Paragraph(text, styles[style])

story = [
    p('Roman Shirokov', 'NameF'),
    p('Senior Backend Engineer | Technical Lead', 'RoleF'),
    p('Kuala Lumpur, Malaysia | +60 10 274 7007 | roman.shirokov.it@gmail.com | linkedin.com/in/roman-shirokov-5b9bb872/', 'ContactF'),
    p('2 August 2026', 'DateF'),
    p('Hiring Manager<br/>First Focus IT', 'BodyF'),
    p('<b>Re: Lead Software Engineer - AI &amp; Automation</b>', 'BodyF'),
    p('Dear Hiring Manager,', 'BodyF'),
    p('I am excited to apply for the Lead Software Engineer - AI &amp; Automation position. I am a Senior Backend Engineer and Technical Lead with more than 10 years of experience building, operating and improving production services, APIs, integrations and high-volume transaction systems. I am at my best when turning complex or ambiguous requirements into secure, reliable and maintainable software that delivers a measurable operational outcome.', 'BodyF'),
    p('In my current role at Xsolla, I develop and maintain payment-related backend services and partner integrations. My work includes REST API design, PostgreSQL performance optimisation, Datadog monitoring, and service operation with Docker and Kubernetes. Previously, at Rosbank, I designed a Redis caching architecture for internal banking services that reduced API response latency by 40%. I have also worked with payment-service integrations including Robokassa, and have contributed to legacy-system modernisation, data integrity and production reliability.', 'BodyF'),
    p('The opportunity to take AI and automation concepts from prototype to stable operational systems strongly matches how I work. I bring practical engineering discipline across system design, testing, CI/CD, deployment, monitoring, documentation and technical leadership. I actively use AI-assisted development tools to accelerate analysis, implementation and documentation while maintaining code quality, security and human accountability. Although my recent production work has centred on PHP-based backend systems, my experience with APIs, cloud-native operations, automation and scalable architecture transfers directly to this role.', 'BodyF'),
    p('I am drawn to First Focus\'s emphasis on useful, adopted technology rather than innovation theatre. Based in Kuala Lumpur, I am ready to relocate to Adelaide. I would require employer sponsorship and would welcome a discussion about whether the Subclass 186 Direct Entry permanent-residency visa could be considered for this ongoing full-time role.', 'BodyF'),
    p('Thank you for considering my application. I would welcome the opportunity to discuss how I can help the AI, Automation &amp; Adoption team build systems that remain secure, supportable and valuable long after launch.', 'BodyF'),
    Spacer(1, 5),
    p('Kind regards,<br/><br/>Roman Shirokov', 'BodyF'),
]

def footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(LINE)
    canvas.setLineWidth(0.5)
    canvas.line(20*mm, 13*mm, 190*mm, 13*mm)
    canvas.setFont('Helvetica', 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(20*mm, 8.5*mm, 'Roman Shirokov | Lead Software Engineer - AI & Automation application')
    canvas.restoreState()

doc = SimpleDocTemplate(str(OUT), pagesize=A4, leftMargin=20*mm, rightMargin=20*mm, topMargin=15*mm, bottomMargin=18*mm, title='Cover Letter - Lead Software Engineer - AI and Automation', author='Roman Shirokov')
doc.build(story, onFirstPage=footer)
print(OUT.resolve())
