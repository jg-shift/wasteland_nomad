from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle

OUT = Path('output/pdf/Roman_Shirokov_Cover_Letter_SA_Health_939541.pdf')
OUT.parent.mkdir(parents=True, exist_ok=True)

NAVY = colors.HexColor('#12314A')
BLUE = colors.HexColor('#176B87')
INK = colors.HexColor('#1C2730')
MUTED = colors.HexColor('#52606D')
LINE = colors.HexColor('#D9E2E8')

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='CLName', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=20, leading=24, textColor=NAVY, spaceAfter=2))
styles.add(ParagraphStyle(name='CLRole', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=10.5, leading=14, textColor=BLUE, spaceAfter=4))
styles.add(ParagraphStyle(name='CLContact', parent=styles['Normal'], fontName='Helvetica', fontSize=8.8, leading=11, textColor=MUTED, spaceAfter=13))
styles.add(ParagraphStyle(name='CLBody', parent=styles['Normal'], fontName='Helvetica', fontSize=10, leading=14.3, textColor=INK, spaceAfter=9))
styles.add(ParagraphStyle(name='CLDate', parent=styles['Normal'], fontName='Helvetica', fontSize=9.5, leading=12, textColor=MUTED, spaceAfter=13))

def p(text, style='CLBody'):
    return Paragraph(text, styles[style])

story = [
    p('Roman Shirokov', 'CLName'),
    p('Senior Backend Engineer | Technical Lead', 'CLRole'),
    p('Kuala Lumpur, Malaysia | +60 10 274 7007 | roman.shirokov.it@gmail.com | linkedin.com/in/roman-shirokov-5b9bb872/', 'CLContact'),
    p('2 August 2026', 'CLDate'),
    p('Ms Rosemary Velardo and Selection Panel<br/>Statewide Clinical Support Services<br/>Central Adelaide Local Health Network', 'CLBody'),
    p('<b>Re: Applications Programmer - Job Reference 939541</b>', 'CLBody'),
    p('Dear Ms Velardo and Selection Panel,', 'CLBody'),
    p('I am writing to apply for the Applications Programmer position with Statewide Clinical Support Services.', 'CLBody'),
    p('I am a Senior Backend Engineer and Technical Lead with more than 10 years of experience designing, developing and supporting business-critical applications, REST APIs and high-volume transaction services. My background in fintech and payments has required a strong focus on reliable systems, data integrity, performance and practical problem-solving - capabilities directly relevant to supporting SCSS applications and digital transformation initiatives.', 'CLBody'),
    p('In my current role at Xsolla, I develop and maintain backend services for payment transactions and partner integrations. I design REST APIs, optimise PostgreSQL performance, implement Datadog monitoring, and work with Docker and Kubernetes to operate dependable production services. Previously, as an IT Architect / Lead Technical Specialist at Rosbank, I designed a Redis caching architecture for internal banking services that reduced API response latency by 40%. I also contributed to legacy-system modernisation, internal tools and audit-related data-integrity work.', 'CLBody'),
    p('I would bring strong programming, systems analysis and solution-design skills to this role. I am comfortable working from business needs through to implementation and ongoing support: investigating issues, prioritising work, communicating technical decisions clearly, and delivering maintainable improvements. I value collaboration with stakeholders and enjoy turning ambiguous requirements into practical, reliable technology solutions.', 'CLBody'),
    p('The opportunity to contribute these skills to services that support the health and wellbeing of South Australians is particularly meaningful to me. I am based in Kuala Lumpur and am ready to relocate to Adelaide. I require employer sponsorship for the Subclass 186 Direct Entry permanent-residency visa and would welcome the opportunity to discuss whether this arrangement is available for the role.', 'CLBody'),
    p('Thank you for considering my application. I would welcome the opportunity to discuss how my technical experience can support SCSS and its transformation initiatives.', 'CLBody'),
    Spacer(1, 5),
    p('Kind regards,<br/><br/>Roman Shirokov', 'CLBody'),
]

def footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(LINE)
    canvas.setLineWidth(0.5)
    canvas.line(20*mm, 13*mm, 190*mm, 13*mm)
    canvas.setFont('Helvetica', 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(20*mm, 8.5*mm, 'Roman Shirokov | Applications Programmer - SA Health')
    canvas.restoreState()

doc = SimpleDocTemplate(str(OUT), pagesize=A4, leftMargin=20*mm, rightMargin=20*mm, topMargin=15*mm, bottomMargin=18*mm, title='Cover Letter - Applications Programmer - SA Health', author='Roman Shirokov')
doc.build(story, onFirstPage=footer)
print(OUT.resolve())
