package org.amnezia.core.models

enum class DnsProvider(val title: String, val subtitle: String, val servers: List<String>) {
    SERVER_DEFAULT("Server Default", "Use the DNS servers from the imported config", emptyList()),
    CLOUDFLARE("Cloudflare", "Fast & privacy-oriented (1.1.1.1)", listOf("1.1.1.1", "1.0.0.1")),
    GOOGLE("Google Public DNS", "High reliability & global reach (8.8.8.8)", listOf("8.8.8.8", "8.8.4.4")),
    QUAD9("Quad9", "Malware blocking & secure (9.9.9.9)", listOf("9.9.9.9", "149.112.112.112")),
    ADGUARD("AdGuard DNS", "Built-in ad & tracker blocking", listOf("94.140.14.14", "94.140.15.15")),
    CUSTOM("Custom DNS", "User defined addresses", emptyList())
}
