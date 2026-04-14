#  Arquitectura Cloud Escalable y Segura (AWS & Terraform)

Este repositorio contiene la definición de una infraestructura moderna, diseñada para soportar cargas de trabajo de producción siguiendo las mejores prácticas de la industria. Busque construir una base sólida enfocada en disponibilidad, seguridad y automatización. Usando localstack, tflocal e awslocal

##  Diagrama de Arquitectura

El siguiente diagrama de alto nivel ilustra el flujo de tráfico y la segregación de capas de nuestra infraestructura. 
```mermaid
graph TB
    Client([Client / Internet]) --> IGW[Internet Gateway]
    
    subgraph "VPC (Virtual Private Cloud - 10.0.0.0/16)"
        direction TB
        IGW --> ALB[Application Load Balancer]
        
        subgraph "Capa Pública (Web Layer)"
            ALB --> ASG[Auto Scaling Group]
            ASG -.-> EC2_A[EC2 Instance - AZ A]
            ASG -.-> EC2_B[EC2 Instance - AZ B]
        end
        
        subgraph "Capa Privada (Data Layer)"
            EC2_A -->|TCP 5432| DB_SG{Security Group Limitado}
            EC2_B -->|TCP 5432| DB_SG
            DB_SG --> RDS[(Amazon RDS - PostgreSQL)]
        end
    end

    %% Estilos mejorados (alto contraste)
    classDef public fill:#1565c0,stroke:#0d47a1,stroke-width:2px,color:#ffffff;
    classDef private fill:#6a1b9a,stroke:#4a148c,stroke-width:2px,color:#ffffff;
    classDef database fill:#ef6c00,stroke:#e65100,stroke-width:2px,color:#ffffff;
    classDef edgeLabel color:#ffffff;

    %% Aplicación de clases
    class ALB,ASG,EC2_A,EC2_B public;
    class RDS database;
    class DB_SG private;

---

## 🛠️ Principios de Diseño Implementados

Esta infraestructura no es simplemente un conjunto de recursos aislados; está diseñada bajo los siguientes pilares de la ingeniería confiable de sistemas (SRE):

### 1. Infraestructura como Código (IaC) 
Toda la infraestructura está provisionada de manera declarativa con **Terraform**. 
- **¿Por qué?** La configuración manual a través de la consola web no es escalable ni auditable. Al usar IaC, logramos configuraciones **reproducibles**, control de versiones exacto de nuestros entornos, capacidades de *rollback*, y la eliminación del *Configuration Drift* (inconsistencias entre entornos).
- **Implementación:** Código modular segmentado por dominio (`network`, `compute`, `database`, `loadbalancer`).

### 2. Seguridad por Diseño (Security by Design) 
Los datos críticos están completamente aislados del internet público. 
- **¿Por qué?** Una base de datos expuesta es la receta para una brecha de seguridad de nivel de exfiltración.
- **Implementación:** Se utiliza una arquitectura de **Múltiples Capas (Multi-Tier)**. La base de datos RDS reside en recursos aprovisionados sobre **Private Subnets** que no tienen rutas directas al *Internet Gateway*. Además, el *Security Group* de la base de datos implementa el principio de privilegio mínimo (Least Privilege), aceptando exclusivamente conexiones que provengan del *Security Group* de la capa web.

### 3. Alta Disponibilidad y Resiliencia (High Availability) 
El sistema está diseñado para sobrevivir a caídas de instancias o picos de tráfico de manera autónoma.
- **¿Por qué?** "Todo falla, todo el tiempo". Debemos diseñar sistemas que se auto-reparen sin necesidad de levantar a un ingeniero a las 3:00 AM.
- **Implementación:** 
  - **Application Load Balancer (ALB):** Actúa como único punto de entrada, distribuyendo dinámicamente el tráfico solo a instancias sanas basadas en *Health Checks* continuos.
  - **Auto Scaling Group (ASG):** Garantiza que siempre tengamos una cantidad mínima deseada de instancias corriendo. Si una VM muere, el ASG la termina y lanza una nueva automáticamente utilizando nuestro *Launch Template* preconfigurado por `user_data`.

---

##  Organización del Proyecto

```text
dia1-vpc/terraform/
├── network_vpc.tf          # Core Network (VPC, Subnets Públicas/Privadas, IGW)
├── network_security.tf     # Hardening (Firewalls perimetrales y de aplicativos)
├── compute_autoscaling.tf  # ASG y Launch Templates (Grupos elásticos)
├── database_rds.tf         # Componente de Almacenamiento Persistente
├── alb_loadbalancer.tf     # Distribución de Tráfico L7
├── locals.tf               # Etiquetado estandarizado corporativo
├── provider.tf             # Declaración de Proveedor (AWS/LocalStack)
└── variables/outputs       # Entradas y exposición de URIs críticas
```

##  Despliegue Local (LocalStack)

Para iteraciones de ciclo de desarrollo rápido e independiente de costos de nube real, estamos usando LocalStack.

1. Asegúrate de tener LocalStack corriendo (`localstack start -d`).
2. Inicializa Terraform:
   ```bash
   tflocal init
   ```
3. Verifica el plan de ejecución:
   ```bash
   tflocal plan
   ```
4. Aplica los cambios a tu nube local:
   ```bash
   tflocal apply
   ```

Una vez finalizado, inspecciona los `outputs` para obtener el puerto de la base de datos o el DNS del Balanceador de Cargas local.
