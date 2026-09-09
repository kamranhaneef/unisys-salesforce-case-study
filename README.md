Repository Setup & Deployment Instructions for Reviewers

### Step-by-Step SFDX Deployment Instructions

#### Prerequisites

* Salesforce CLI installed (`sf` / `sfdx`).
* Authorized Developer Org or Scratch Org.

#### 1. Clone the Repository

```bash
git clone https://github.com/kamranhaneef/unisys-salesforce-case-study.git
cd unisys-salesforce-case-study

```

#### 2. Authenticate Target Org

```bash
sf org login web --alias TargetOrg --set-default

```

#### 3. Deploy Source Metadata

```bash
sf project deploy start --target-org TargetOrg --source-dir force-app

```

#### 4. Assign Permission Sets

```bash
sf org assign permset --name Gestor_Servicios_Permissions --target-org TargetOrg

```

#### 5. Schedule Batch Apex Jobs

Run the following Anonymous Apex snippet in Developer Console or via CLI:

```java
// Schedule Daily Approval Batch at 17:00
System.schedule('Daily Service Approval Job', '0 0 17 * * ?', new ApproveServicesBatch());

// Schedule Daily Incident Processing Job at 20:00
System.schedule('Daily Case Processing Job', '0 0 20 * * ?', new ProcessCasesBatch());

```

---

