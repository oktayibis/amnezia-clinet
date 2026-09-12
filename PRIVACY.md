# Privacy Policy for AWG Connect

**Effective Date:** September 12, 2026  
**Last Updated:** September 12, 2026

**AWG Connect** ("the Application") is an open-source, client-only application developed by Oktay Ibis. This Privacy Policy describes how your information is handled when using the Application on iOS and macOS.

---

### 1. No Data Collection
AWG Connect does **not** collect, store, transmit, log, track, or share any personal information, usage metrics, diagnostic telemetry, or device identifiers. 

- **No User Accounts:** You do not need to register, provide an email address, or create an account to use the Application.
- **No Analytics or Trackers:** There are no third-party analytics frameworks, advertising SDKs, tracking libraries, or telemetry services embedded in the Application.
- **Zero Logging:** The developer has no access to your IP address, browsing activity, connection timestamps, or transferred data volume.

---

### 2. Local Storage of Connection Configurations
All VPN server configurations (including server addresses, port numbers, public/private cryptographic keys, preshared keys, and obfuscation parameters) are stored **exclusively on your local device**:
- Configurations are saved within the Application's local sandbox or shared App Group container solely to enable the operating system's Network Extension framework to establish tunnel connections.
- Configurations are never uploaded to any remote server operated by the developer or any third party.

---

### 3. Network Traffic Routing
When a VPN tunnel is established:
- Your network traffic is routed directly between your device and the VPN server endpoint you configured.
- The developer does not operate, route, proxy, inspect, or have access to any server infrastructure or network traffic passing through your tunnel.
- You are solely responsible for the privacy practices and logging policies of the third-party VPN servers to which you connect.

---

### 4. Device Permissions
The Application requests only the minimal system permissions required for operation:
- **Camera Access (iOS only):** Used solely in real-time to scan VPN configuration QR codes. Images from the camera are processed on-device and are never stored or transmitted.
- **Photo Library Access (iOS only):** Used only when you explicitly select a screenshot or image of a QR code to import.
- **Network Extension / VPN Configuration:** Used solely to install and control the on-device system VPN profile via Apple's `NetworkExtension` framework.

---

### 5. Children's Privacy
Because the Application does not collect any personal data whatsoever, it does not knowingly collect information from children under the age of 13 or any other age group.

---

### 6. Open Source Verification
AWG Connect is open-source software licensed under the MIT License. You can inspect the complete source code to independently verify our privacy practices:
[https://github.com/oktayibis/amnezia-clinet](https://github.com/oktayibis/amnezia-clinet)

---

### 7. Changes to This Privacy Policy
If this Privacy Policy is updated, the changes will be posted in this document and reflected in the Application repository.

---

### 8. Contact
If you have any questions or feedback regarding this Privacy Policy, please open an issue on GitHub:  
[https://github.com/oktayibis/amnezia-clinet/issues](https://github.com/oktayibis/amnezia-clinet/issues)
