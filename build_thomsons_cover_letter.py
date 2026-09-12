from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer

OUT = Path('output/pdf/Roman_Shirokov_Cover_Letter_Thomsons_Cloud_Software_Engineer.pdf')
OUT.parent.mkdir(parents=True, exist_ok=True)

NAVY = colors.HexColor('#12314A')
BLUE = colors.HexColor('#176B87')
INK = colors.HexColor('#1C2730')
MUTED = colors.HexColor('#52606D')
LINE = colors.HexColor('#D9E2E8')

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='NameX', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=20, leading=24, textColor=NAVY, spaceAfter=2))
styles.add(ParagraphStyle(name='RoleX', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=10.5, leading=14, textColor=BLUE, spaceAfter=4))
styles.add(ParagraphStyle(name='ContactX', parent=styles['Normal'], fontName='Helvetica', fontSize=8.8, leading=11, textColor=MUTED, spaceAfter=13))
styles.add(ParagraphStyle(name='BodyX', parent=styles['Normal'], fontName='Helvetica', fontSize=10, leading=14.3, textColor=INK, spaceAfter=9))
styles.add(ParagraphStyle(name='DateX', parent=styles['Normal'], fontName='Helvetica', fontSize=9.5, leading=12, textColor=MUTED, spaceAfter=13))

def p(text, style='BodyX'):
    return Paragraph(text, styles[style])

story = [
    p('Roman Shirokov', 'NameX'),
    p('Senior Backend Engineer | Technical Lead', 'RoleX'),
    p('Kuala Lumpur, Malaysia | +60 10 274 7007 | roman.shirokov.it@gmail.com | linkedin.com/in/roman-shirokov-5b9bb872/', 'ContactX'),
    p('2 August 2026', 'DateX'),
    p('Hiring Manager<br/>Thomsons / Faculti Lawyers', 'BodyX'),
    p('<b>Re: Cloud Software Engineer</b>', 'BodyX'),
    p('Dear Hiring Manager,', 'BodyX'),
    p('I am excited to apply for the Cloud Software Engineer position. I am a Senior Backend Engineer and Technical Lead with more than 10 years of experience building and operating business-critical services, APIs and high-volume transaction systems. I combine hands-on engineering with system design, production reliability and a practical approach to technical ownership.', 'BodyX'),
    p('In my current role at Xsolla, I develop and maintain payment-related backend services and partner integrations. My work includes REST API development, PostgreSQL performance optimisation, Datadog monitoring, and deploying services with Docker and Kubernetes. Previously, as an IT Architect / Lead Technical Specialist at Rosbank, I designed a Redis caching architecture for internal banking services that reduced API response latency by 40%, while also contributing to legacy-system modernisation and data-integrity work.', 'BodyX'),
    p('The opportunity to build cloud-native, API-first applications and improve delivery practices strongly matches my experience. I have designed and supported CI/CD workflows, production monitoring and scalable backend services, and I enjoy collaborating with stakeholders to turn complex requirements into secure, maintainable solutions. I am particularly interested in the role\'s focus on automation, observability and agentic AI integrations. My recent backend work has centred on PHP and cloud-native tooling; I am ready to apply this foundation while developing deeper capability in the Azure and .NET environment.', 'BodyX'),
    p('I am drawn to Thomsons because of its technology-enabled approach to complex, high-volume services. Based in Kuala Lumpur, I am ready to relocate to Adelaide. I would require employer sponsorship and would welcome a discussion about whether the Subclass 186 Direct Entry permanent-residency visa could be considered for this ongoing full-time role.', 'BodyX'),
    p('Thank you for considering my application. I would welcome the opportunity to discuss how my experience can contribute to your technology team.', 'BodyX'),
    Spacer(1, 5),
    p('Kind regards,<br/><br/>Roman Shirokov', 'BodyX'),
]

def footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(LINE)
    canvas.setLineWidth(0.5)
    canvas.line(20*mm, 13*mm, 190*mm, 13*mm)
    canvas.setFont('Helvetica', 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(20*mm, 8.5*mm, 'Roman Shirokov | Cloud Software Engineer application')
    canvas.restoreState()

doc = SimpleDocTemplate(str(OUT), pagesize=A4, leftMargin=20*mm, rightMargin=20*mm, topMargin=15*mm, bottomMargin=18*mm, title='Cover Letter - Cloud Software Engineer', author='Roman Shirokov')
doc.build(story, onFirstPage=footer)
print(OUT.resolve())
