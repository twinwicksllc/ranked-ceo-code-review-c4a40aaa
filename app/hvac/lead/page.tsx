import { redirect } from 'next/navigation'
import Link from 'next/link'
import { Flame } from 'lucide-react'
import { HvacLeadForm } from '@/components/hvac/hvac-lead-form'
import { submitIndustryLead } from '@/lib/actions/industry-lead'
import type { HvacLeadInput } from '@/lib/validations/industry-lead'
import { ChatWidget } from '@/components/agent/chat-widget'

export const dynamic = 'force-dynamic'
export const revalidate = 0

async function HvacLeadFormWrapper({ operatorId }: { operatorId?: string }) {
  async function handleSubmit(formData: HvacLeadInput) {
    'use server'
    const result = await submitIndustryLead({ ...formData, operator_id: operatorId ?? null })
    if (result.success) {
      redirect('/lead/success')
    } else {
      throw new Error(result.error || 'Submission failed')
    }
  }

  return <HvacLeadForm onSubmit={handleSubmit} operatorId={operatorId} />
}

export default async function HvacLeadPage({
  searchParams,
}: {
  searchParams: { operatorId?: string }
}) {
  const operatorId = searchParams.operatorId

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-25">
      {/* Header */}
      <div className="border-b border-blue-200 bg-white bg-opacity-80 backdrop-blur-sm sticky top-0 z-10">
        <div className="mx-auto max-w-7xl px-4 py-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="rounded-full bg-blue-100 p-2">
                <Flame className="h-6 w-6 text-blue-600" />
              </div>
              <div>
                <p className="text-lg font-bold text-gray-900">HVAC Pro</p>
                <p className="text-xs text-blue-600 font-medium">Service Request</p>
              </div>
            </div>
            <Link href="/login">
              <span className="text-sm text-blue-600 hover:underline">Operator Login →</span>
            </Link>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="mx-auto max-w-2xl px-4 py-10 sm:px-6 lg:px-8">
        <div className="mb-8 text-center">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Request HVAC Service
          </h1>
          <p className="text-gray-500">
            Fill out this quick form and a certified HVAC technician will contact you shortly.
          </p>
        </div>

        <HvacLeadFormWrapper operatorId={operatorId} />

        {/* Trust signals */}
        <div className="mt-8 grid grid-cols-3 gap-4 text-center">
          {[
            { icon: '⚡', label: 'Fast Response', sub: 'Same-day available' },
            { icon: '🔧', label: 'Certified Techs', sub: 'Licensed & insured' },
            { icon: '💰', label: 'Free Estimates', sub: 'No obligation' },
          ].map(item => (
            <div key={item.label} className="rounded-lg border border-blue-100 bg-white p-3">
              <div className="text-2xl mb-1">{item.icon}</div>
              <p className="text-xs font-semibold text-gray-700">{item.label}</p>
              <p className="text-xs text-gray-400">{item.sub}</p>
            </div>
          ))}
        </div>
      </div>

      <ChatWidget
        source="hvac"
        primaryColor="#2563eb"
        position="bottom-right"
      />
    </div>
  )
}