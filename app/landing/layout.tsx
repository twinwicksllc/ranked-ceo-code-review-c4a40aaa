import './style.css'

export const metadata = {
  title: 'Smile MakeOver | Affordable Veneers & Cosmetic Dentistry',
  description: 'Get a brand new smile for less than you think. Premium cosmetic dentistry with affordable financing options.',
}

export default function LandingLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <head>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet" />
      </head>
      <body style={{ margin: 0, padding: 0 }}>
        {children}
      </body>
    </html>
  )
}
