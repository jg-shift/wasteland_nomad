from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, KeepTogether
)

OUT = Path('output/pdf/Roman_Shirokov_Senior_Backend_Engineer_CV.pdf')
OUT.parent.mkdir(parents=True, exist_ok=True)

NAVY = colors.HexColor('#12314A')
BLUE = colors.HexColor('#176B87')
INK = colors.HexColor('#1C2730')
MUTED = colors.HexColor('#52606D')
LINE = colors.HexColor('#D9E2E8')

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='Name', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=21, leading=24, textColor=NAVY, spaceAfter=2))
styles.add(ParagraphStyle(name='Headline', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=10.7, leading=14, textColor=BLUE, spaceAfter=5))
styles.add(ParagraphStyle(name='Contact', parent=styles['Normal'], fontName='Helvetica', fontSize=8.8, leading=11, textColor=MUTED, spaceAfter=9))
styles.add(ParagraphStyle(name='Section', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=10.5, leading=13, textColor=NAVY, spaceBefore=7, spaceAfter=4))
styles.add(ParagraphStyle(name='Body', parent=styles['Normal'], fontName='Helvetica', fontSize=9.1, leading=12.5, textColor=INK, spaceAfter=3))
styles.add(ParagraphStyle(name='Role', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=9.8, leading=12, textColor=INK))
styles.add(ParagraphStyle(name='Meta', parent=styles['Normal'], fontName='Helvetica', fontSize=8.6, leading=11, textColor=MUTED, alignment=TA_LEFT))
styles.add(ParagraphStyle(name='AptBullet', parent=styles['Normal'], fontName='Helvetica', fontSize=8.9, leading=11.7, textColor=INK, leftIndent=10, firstLineIndent=-7, spaceAfter=1.5))
styles.add(ParagraphStyle(name='Skill', parent=styles['Normal'], fontName='Helvetica', fontSize=8.8, leading=11.5, textColor=INK))

def P(text, style='Body'):
    return Paragraph(text, styles[style])

def bullets(items):
    return [P('&bull; ' + item, 'AptBullet') for item in items]

def section(title):
    table = Table([[P(title.upper(), 'Section')]], colWidths=[170 * mm])
    table.setStyle(TableStyle([
        ('LINEBELOW', (0, 0), (-1, -1), 0.7, LINE),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 2),
        ('TOPPADDING', (0, 0), (-1, -1), 0),
    ]))
    return table

def role(title, company, dates, items):
    head = Table([[P(title, 'Role'), P(dates, 'Meta')]], colWidths=[126 * mm, 44 * mm])
    head.setStyle(TableStyle([('VALIGN', (0, 0), (-1, -1), 'TOP'), ('ALIGN', (1, 0), (1, 0), 'RIGHT'), ('BOTTOMPADDING', (0, 0), (-1, -1), 1)]))
    return KeepTogether([head, P(company, 'Meta')] + bullets(items) + [Spacer(1, 4)])

story = []
story += [P('Roman Shirokov', 'Name')]
story += [P('SENIOR BACKEND ENGINEER | TECHNICAL LEAD | PAYMENTS, FINTECH &amp; SYSTEM ARCHITECTURE', 'Headline')]
story += [P('Kuala Lumpur, Malaysia | Open to relocate to Adelaide, South Australia | +60 10 274 7007 | roman.shirokov.it@gmail.com | linkedin.com/in/roman-shirokov-5b9bb872/', 'Contact')]

story += [section('Professional Summary'), Spacer(1, 4)]
story += [P('<b>Senior Backend Engineer and Technical Lead</b> with 10+ years of experience delivering high-load backend services, payment platforms and scalable APIs. Combines hands-on engineering with pragmatic system design: translates business needs into reliable, maintainable architecture; improves performance; and operates production systems with strong observability. Deep expertise in PHP, PostgreSQL, Redis, Docker, Kubernetes, CI/CD and Datadog. Open to employer-sponsored relocation to Adelaide and ready to pursue the Subclass 186 Direct Entry permanent-residency pathway.', 'Body')]

story += [section('Core Expertise'), Spacer(1, 4)]
skills = [
    ('Backend & APIs', 'PHP, REST APIs, microservices, partner integrations, Go, Python, JavaScript'),
    ('Data & Performance', 'PostgreSQL, MySQL, Redis, SQL tuning, caching, profiling, high-load systems'),
    ('Architecture & Reliability', 'System design, scalable services, legacy modernisation, monitoring, logging, incident troubleshooting'),
    ('Platform & Delivery', 'Docker, Kubernetes, Linux, Git, CI/CD, Datadog, production operations'),
    ('Domain Leadership', 'Payments, fintech, transaction processing, technical leadership, stakeholder communication'),
]
skill_data = [[P(f'<b>{a}</b>', 'Skill'), P(b, 'Skill')] for a, b in skills]
skill_table = Table(skill_data, colWidths=[42*mm, 128*mm], hAlign='LEFT')
skill_table.setStyle(TableStyle([('VALIGN', (0,0), (-1,-1), 'TOP'), ('BOTTOMPADDING', (0,0), (-1,-1), 3)]))
story += [skill_table]

story += [section('Professional Experience'), Spacer(1, 4)]
story += [role('PHP Developer / Backend Engineer', 'Xsolla', 'Sep 2023 - Present', [
    'Build and maintain backend services that support payment transactions and partner integrations.',
    'Design and deliver REST APIs used by internal systems and external partners.',
    'Improve service performance through PostgreSQL query optimisation and production troubleshooting.',
    'Implement Datadog metrics and monitoring to improve observability of production services.',
    'Work with Docker and Kubernetes for deployment and operation; developed a Godot 4 plugin for Xsolla Web Shop payments.',
])]
story += [role('IT Architect / Lead Technical Specialist', 'Rosbank', 'Dec 2019 - Sep 2023', [
    'Designed Redis caching architecture for internal banking services, reducing API response latency by 40%.',
    'Contributed to modernisation of legacy banking systems and the design of dependable internal services.',
    'Built internal fintech tools and CMS modules, and supported audit preparation and data-integrity checks.',
    'Provided technical leadership through architecture decisions, performance analysis and cross-functional collaboration.',
])]
story += [role('Lead PHP Developer', 'Mail.ru Group (ESforce)', 'Aug 2017 - Sep 2018', [
    'Developed backend services for esports tournament management and real-time event processing.',
    'Improved analytics and reporting pipelines for platform operations.',
])]
story += [role('Backend Developer', 'NX Studio / RuMed / inPlat / Stampa Viva', 'Jan 2009 - Jul 2017', [
    'Developed REST APIs, payment integrations and real-time data aggregation services across multiple products.',
    'Refactored and extended legacy applications while maintaining production stability.',
])]

story += [section('Education & Professional Development'), Spacer(1, 4)]
story += [P('<b>Bachelor of Computer Science</b> | Russian New University, Moscow | 2001 - 2007<br/>Coursework: algorithms, software engineering, distributed systems. Diploma project: Computer Vision.', 'Body')]
story += [P('<b>Soft Skills for Engineers</b> | 80 hours of theory and practice<br/>Professional development in communicating technical decisions, collaborating with management and aligning engineering work with business goals.', 'Body')]

story += [section('Languages'), Spacer(1, 4)]
story += [P('Russian - Native | English - Upper-intermediate (B2+) | Spanish - Basic', 'Body')]

def footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(LINE)
    canvas.setLineWidth(0.5)
    canvas.line(20*mm, 13*mm, 190*mm, 13*mm)
    canvas.setFont('Helvetica', 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(20*mm, 8.5*mm, 'Roman Shirokov | Senior Backend Engineer')
    canvas.drawRightString(190*mm, 8.5*mm, f'Page {doc.page}')
    canvas.restoreState()

doc = SimpleDocTemplate(str(OUT), pagesize=A4, leftMargin=20*mm, rightMargin=20*mm, topMargin=15*mm, bottomMargin=18*mm, title='Roman Shirokov - Senior Backend Engineer CV', author='Roman Shirokov')
doc.build(story, onFirstPage=footer, onLaterPages=footer)
print(OUT.resolve())
