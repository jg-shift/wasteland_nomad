from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer

OUT = Path('output/pdf/Roman_Shirokov_Cover_Letter_MyVenue_Integrations_Engineer.pdf')
OUT.parent.mkdir(parents=True, exist_ok=True)

NAVY = colors.HexColor('#12314A')
BLUE = colors.HexColor('#176B87')
INK = colors.HexColor('#1C2730')
MUTED = colors.HexColor('#52606D')
LINE = colors.HexColor('#D9E2E8')

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='NameM', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=20, leading=24, textColor=NAVY, spaceAfter=2))
styles.add(ParagraphStyle(name='RoleM', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=10.5, leading=14, textColor=BLUE, spaceAfter=4))
styles.add(ParagraphStyle(name='ContactM', parent=styles['Normal'], fontName='Helvetica', fontSize=8.8, leading=11, textColor=MUTED, spaceAfter=13))
styles.add(ParagraphStyle(name='BodyM', parent=styles['Normal'], fontName='Helvetica', fontSize=10, leading=14.3, textColor=INK, spaceAfter=9))
styles.add(ParagraphStyle(name='DateM', parent=styles['Normal'], fontName='Helvetica', fontSize=9.5, leading=12, textColor=MUTED, spaceAfter=13))

def p(text, style='BodyM'):
    return Paragraph(text, styles[style])

story = [
    p('Roman Shirokov', 'NameM'),
    p('Senior Backend Engineer | Technical Lead', 'RoleM'),
    p('Kuala Lumpur, Malaysia | +60 10 274 7007 | roman.shirokov.it@gmail.com | linkedin.com/in/roman-shirokov-5b9bb872/', 'ContactM'),
    p('2 August 2026', 'DateM'),
    p('Hiring Manager<br/>MyVenue', 'BodyM'),
    p('<b>Re: Integrations Engineer</b>', 'BodyM'),
    p('Dear Hiring Manager,', 'BodyM'),
    p('I am excited to apply for the Integrations Engineer position at MyVenue. I am a Senior Backend Engineer and Technical Lead with more than 10 years of experience delivering reliable APIs, partner integrations and high-volume transaction services. My work is centred on making complex systems communicate reliably: translating business needs into practical technical designs, building integrations end-to-end, and supporting them in production.', 'BodyM'),
    p('In my current role at Xsolla, I develop and maintain backend services for payment transactions and partner integrations. I build REST APIs, improve PostgreSQL performance, and implement Datadog monitoring for production services. Earlier in my career, I also worked with payment-service integrations including Robokassa. Previously, as an IT Architect / Lead Technical Specialist at Rosbank, I designed a Redis caching architecture for internal banking services that reduced API response latency by 40%. Across these roles, I have worked with authentication, data exchange, error handling, logging, performance optimisation and operational troubleshooting in systems where reliability and data integrity are critical.', 'BodyM'),
    p('I would bring strong experience in API design, integration specifications and stakeholder communication. I am comfortable taking an integration from requirements through technical design, implementation, testing, documentation and ongoing support. My hands-on backend experience is primarily in PHP and cloud-native tooling rather than C#/.NET; however, the core practices of secure REST integrations, asynchronous processing, robust error handling and maintainable service design are central to my work and directly transferable to the MyVenue platform.', 'BodyM'),
    p('I am particularly interested in MyVenue\'s focus on scalable SaaS integrations and reliable data exchange across external systems. Based in Kuala Lumpur, I am ready to relocate to Adelaide. I would require employer sponsorship and would welcome a discussion about whether the Subclass 186 Direct Entry permanent-residency visa could be considered for this ongoing full-time role.', 'BodyM'),
    p('Thank you for considering my application. I would welcome the opportunity to discuss how my integration and backend experience can contribute to MyVenue.', 'BodyM'),
    Spacer(1, 5),
    p('Kind regards,<br/><br/>Roman Shirokov', 'BodyM'),
]

def footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(LINE)
    canvas.setLineWidth(0.5)
    canvas.line(20*mm, 13*mm, 190*mm, 13*mm)
    canvas.setFont('Helvetica', 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(20*mm, 8.5*mm, 'Roman Shirokov | Integrations Engineer application')
    canvas.restoreState()

doc = SimpleDocTemplate(str(OUT), pagesize=A4, leftMargin=20*mm, rightMargin=20*mm, topMargin=15*mm, bottomMargin=18*mm, title='Cover Letter - Integrations Engineer - MyVenue', author='Roman Shirokov')
doc.build(story, onFirstPage=footer)
print(OUT.resolve())
