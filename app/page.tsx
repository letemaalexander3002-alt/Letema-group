import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen bg-[#0a1628] text-white font-sans">
      <div className="max-w-4xl mx-auto px-6 py-16">
        {/* Header */}
        <div className="text-center mb-16">
          <h1 className="text-4xl md:text-5xl font-bold tracking-tight mb-4" style={{ fontFamily: "'Playfair Display', serif", color: "#c9972a" }}>
            LETEMA GROUP
          </h1>
          <p className="text-lg text-gray-400 max-w-2xl mx-auto">
            Mfumo Kamili wa Supabase Integration na Global Translation System
          </p>
        </div>

        {/* Files Grid */}
        <div className="grid md:grid-cols-2 gap-6 mb-16">
          {/* Index */}
          <Link 
            href="/index.html" 
            className="block p-6 rounded-xl border border-[#c9972a]/20 bg-[#122240] hover:border-[#c9972a]/50 transition-colors"
          >
            <div className="text-3xl mb-4">🌐</div>
            <h2 className="text-xl font-bold text-white mb-2">Index (Tovuti Kuu)</h2>
            <p className="text-gray-400 text-sm">Landing page kuu ya Letema Group na fomu za kujiunga.</p>
          </Link>

          {/* Admin */}
          <Link 
            href="/letema_admin.html" 
            className="block p-6 rounded-xl border border-[#c9972a]/20 bg-[#122240] hover:border-[#c9972a]/50 transition-colors"
          >
            <div className="text-3xl mb-4">⚙️</div>
            <h2 className="text-xl font-bold text-white mb-2">Admin Panel</h2>
            <p className="text-gray-400 text-sm">Control Centre kwa kusimamia leads, wanachama, na directives.</p>
          </Link>

          {/* Portal */}
          <Link 
            href="/letema_portal.html" 
            className="block p-6 rounded-xl border border-[#c9972a]/20 bg-[#122240] hover:border-[#c9972a]/50 transition-colors"
          >
            <div className="text-3xl mb-4">🚪</div>
            <h2 className="text-xl font-bold text-white mb-2">Member Portal</h2>
            <p className="text-gray-400 text-sm">Dashboard ya wanachama - directives, resources, na profile.</p>
          </Link>

          {/* Toolkit */}
          <Link 
            href="/letema_conversion_toolkit.html" 
            className="block p-6 rounded-xl border border-[#c9972a]/20 bg-[#122240] hover:border-[#c9972a]/50 transition-colors"
          >
            <div className="text-3xl mb-4">🛠️</div>
            <h2 className="text-xl font-bold text-white mb-2">Conversion Toolkit</h2>
            <p className="text-gray-400 text-sm">Zana za prospecting - Ecosystem Map, Recruitment Page, WhatsApp Kit.</p>
          </Link>
        </div>

        {/* Info Section */}
        <div className="p-6 rounded-xl border border-[#c9972a]/20 bg-[#122240]/50 mb-8">
          <h3 className="text-lg font-bold text-[#c9972a] mb-4">Jinsi ya Kutumia</h3>
          <ul className="space-y-3 text-gray-400 text-sm">
            <li className="flex items-start gap-3">
              <span className="text-[#c9972a]">1.</span>
              <span>Endesha <code className="bg-[#0a1628] px-2 py-0.5 rounded text-[#e8b84b]">letema_schema.sql</code> kwenye Supabase SQL Editor</span>
            </li>
            <li className="flex items-start gap-3">
              <span className="text-[#c9972a]">2.</span>
              <span>Tengeneza admin wa kwanza kwa kusajili kwenye Supabase Auth</span>
            </li>
            <li className="flex items-start gap-3">
              <span className="text-[#c9972a]">3.</span>
              <span>Badilisha role kuwa admin: <code className="bg-[#0a1628] px-2 py-0.5 rounded text-[#e8b84b]">UPDATE profiles SET role = &apos;admin&apos; WHERE email = &apos;your@email.com&apos;</code></span>
            </li>
            <li className="flex items-start gap-3">
              <span className="text-[#c9972a]">4.</span>
              <span>Lugha inayochaguliwa kwenye ukurasa wowote inatumika kote (Global Sync)</span>
            </li>
          </ul>
        </div>

        {/* SQL Schema Link */}
        <div className="text-center">
          <Link 
            href="/letema_schema.sql" 
            className="inline-flex items-center gap-2 px-6 py-3 rounded-lg bg-[#c9972a] text-[#0a1628] font-bold hover:bg-[#e8b84b] transition-colors"
          >
            📄 Download SQL Schema
          </Link>
        </div>
      </div>
    </div>
  );
}
