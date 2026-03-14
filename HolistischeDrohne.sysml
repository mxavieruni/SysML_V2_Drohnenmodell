package DrohneUAM {

    public import ScalarValues::*;
    public import SI::*;

    // =========================================================
    // 1. ANFORDERUNG – nur Friis-relevant
    // =========================================================
    requirement def ReichweiteReq {
        doc /* Empfangsleistung bei Maximalreichweite muss
               Mindestempfindlichkeit des Empfängers erfüllen. */
        attribute P_r_ist : Real;
        attribute P_r_min : Real = -85.0; // dBm
        require { P_r_ist >= P_r_min }
    }

    // =========================================================
    // 2. PORT – nur HF-Schnittstelle
    // =========================================================
    port def HFPort {
        attribute frequenz : Real; // Hz
        attribute leistung : Real; // dBm
    }

    // =========================================================
    // 3. STRUKTURDEFINITIONEN – alle als Blackbox
    // =========================================================
    part def SensorSubsystem {
        doc /* Blackbox – IMU, Barometer, GPS */
    }

    part def NavigationsSubsystem {
        doc /* Blackbox – GPS-Fusion, kooperative Ortung */
    }

    part def Antriebseinheit {
        doc /* Blackbox – Motor und Propeller */
    }

    part def Batteriesystem {
        doc /* Blackbox – LiPo Energieversorgung */
    }

    // =========================================================
    // 4. KOMMUNIKATIONSSUBSYSTEM – vollständig (Friis-Fokus)
    // =========================================================
    part def KommunikationsSubsystem {
        doc /* Bidirektionale Funkverbindung zwischen
               Controller (Sender) und Drohne (Empfänger). */

        attribute sendeleistung_dBm      : Real = 20.0;  // dBm
        attribute sendeAntennenGewinn    : Real = 2.15;  // dBi
        attribute empfangsAntennenGewinn : Real = 2.15;  // dBi
        attribute mindestEmpfindlichkeit : Real = -85.0; // dBm
        attribute frequenz_GHz           : Real = 2.4;   // GHz
        attribute maxReichweite          : Real = 500.0; // m

        port funkSchnittstelle : HFPort;

        satisfy ReichweiteReq;
    }

    // =========================================================
    // 5. DROHNE – MBSE-Plattformmodell
    // =========================================================
    part def Drohne {
        doc /* UAM-Drohne nach Topal et al. (2025) */

        // Subsysteme – Blackbox
        part batterie      : Batteriesystem;
        part sensor        : SensorSubsystem;
        part navigation    : NavigationsSubsystem;
        part rotor1        : Antriebseinheit;
        part rotor2        : Antriebseinheit;
        part rotor3        : Antriebseinheit;
        part rotor4        : Antriebseinheit;

        // Kommunikation – vollständig modelliert
        part kommunikation : KommunikationsSubsystem;
    }

    // =========================================================
    // 6. ANALYSEFALL – Schnittstelle zu MATLAB
    // =========================================================
    analysis def FriisReichweite {
        doc /*
            P_r = P_t + G_t + G_r + 20·log10(λ / (4π·d))
            Parameter über SysML-v2-REST-API an MATLAB.
        */
        subject drohne : Drohne;

        return attribute P_r_bei_maxReichweite : Real;   // dBm
        return attribute anforderungErfuellt   : Boolean;
        return attribute grenzReichweite       : Real;   // m
    }

    // =========================================================
    // 7. SYSTEMINSTANZ
    // =========================================================
    part holisticUAM_Drohne : Drohne;
}
```

---

## Struktur auf einen Blick
```
DrohneUAM
├── ReichweiteReq          ← einzige Anforderung
├── HFPort                 ← einziger Port
│
├── Batteriesystem         ← Blackbox
├── SensorSubsystem        ← Blackbox
├── NavigationsSubsystem   ← Blackbox
├── Antriebseinheit        ← Blackbox
│
├── KommunikationsSubsystem ← vollständig (6 Attribute)
│
├── Drohne                 ← verbindet alles
├── FriisReichweite        ← MATLAB-Schnittstelle
└── holisticUAM_Drohne     ← Instanz
