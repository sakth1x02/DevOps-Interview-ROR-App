# Architecture Diagram

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                AWS Cloud                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐        │
│  │   GitHub Repo   │    │   CodePipeline  │    │   CodeBuild     │        │
│  │                 │    │                 │    │                 │        │
│  │  Rails App      │───▶│  Source Stage   │───▶│  Build Images   │        │
│  │  Code           │    │  Build Stage    │    │  Push to ECR    │        │
│  │                 │    │  Deploy Stage   │    │                 │        │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘        │
│                                │                                              │
│                                ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                              VPC                                        │ │
│  │                                                                         │ │
│  │  ┌─────────────────┐                    ┌─────────────────┐            │ │
│  │  │   Public Subnet │                    │  Private Subnet │            │ │
│  │  │                 │                    │                 │            │ │
│  │  │  ┌─────────────┐│                    │  ┌─────────────┐│            │ │
│  │  │  │Application  ││                    │  │   ECS       ││            │ │
│  │  │  │Load Balancer││                    │  │  Cluster    ││            │ │
│  │  │  │             ││                    │  │             ││            │ │
│  │  │  │  Port 80    ││                    │  │┌───────────┐││            │ │
│  │  │  │  Port 443   ││                    │  ││Rails App  │││            │ │
│  │  │  └─────────────┘│                    │  ││Container  │││            │ │
│  │  │                 │                    │  ││Port 3000  │││            │ │
│  │  │  ┌─────────────┐│                    │  │└───────────┘││            │ │
│  │  │  │   Internet  ││                    │  │┌───────────┐││            │ │
│  │  │  │   Gateway   ││                    │  ││Nginx Proxy│││            │ │
│  │  │  └─────────────┘│                    │  ││Container  │││            │ │
│  │  │                 │                    │  ││Port 80    │││            │ │
│  │  │  ┌─────────────┐│                    │  │└───────────┘││            │ │
│  │  │  │   NAT       ││                    │  │             ││            │ │
│  │  │  │  Gateway    ││                    │  │  ┌─────────┐││            │ │
│  │  │  └─────────────┘│                    │  │  │   RDS   │││            │ │
│  │  └─────────────────┘                    │  │  │PostgreSQL│││            │ │
│  │                                         │  │  │Port 5432 │││            │ │
│  │                                         │  │  └─────────┘││            │ │
│  │                                         │  └─────────────┘│            │ │
│  └─────────────────────────────────────────┘                 │            │
│                                                              │            │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                              S3                                         │ │
│  │                                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                │ │
│  │  │   App Files │    │Pipeline Artifacts│ │Terraform State│                │ │
│  │  │   Storage   │    │             │    │             │                │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘                │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                           Secrets Manager                              │ │
│  │                                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                │ │
│  │  │ RDS Credentials│ │ S3 Config   │    │ LB Endpoint │                │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘                │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. User Request Flow
```
Internet → Application Load Balancer → Nginx Proxy → Rails App → RDS Database
```

### 2. Deployment Flow
```
GitHub Push → CodePipeline → CodeBuild → ECR → CodeDeploy → ECS → ALB
```

### 3. File Storage Flow
```
Rails App → S3 Bucket (via IAM Role)
```

## Security Architecture

### Network Security
- **Public Subnets**: Only ALB and NAT Gateway
- **Private Subnets**: ECS tasks and RDS database
- **Security Groups**: Minimal required access
- **NACLs**: Default deny, explicit allow

### Data Security
- **Encryption at Rest**: RDS and S3
- **Encryption in Transit**: TLS/SSL for all connections
- **Secrets Management**: AWS Secrets Manager
- **IAM Roles**: Least privilege access

### Application Security
- **Container Security**: ECS Fargate isolation
- **Image Security**: ECR with vulnerability scanning
- **Runtime Security**: CloudWatch monitoring

## Scalability Design

### Horizontal Scaling
- **ECS Auto Scaling**: Based on CPU/memory metrics
- **ALB**: Distributes traffic across multiple containers
- **RDS**: Read replicas for read scaling

### Vertical Scaling
- **ECS Task Definition**: CPU/memory allocation
- **RDS Instance**: Instance class upgrades
- **ALB**: Enhanced features for high traffic

## High Availability

### Multi-AZ Deployment
- **VPC**: Spans multiple availability zones
- **ECS**: Tasks distributed across AZs
- **RDS**: Multi-AZ deployment
- **ALB**: Cross-zone load balancing

### Disaster Recovery
- **Backup Strategy**: RDS automated backups
- **Data Replication**: S3 cross-region replication
- **Infrastructure**: Terraform state management

## Monitoring and Observability

### Logging
- **Application Logs**: CloudWatch Logs
- **Container Logs**: ECS task logs
- **Access Logs**: ALB access logs

### Metrics
- **Infrastructure**: CloudWatch metrics
- **Application**: Custom application metrics
- **Database**: RDS performance insights

### Alerting
- **CloudWatch Alarms**: CPU, memory, error rates
- **SNS Notifications**: Critical alerts
- **Dashboard**: CloudWatch dashboards

## Cost Optimization

### Resource Optimization
- **Fargate Spot**: Non-production workloads
- **RDS Reserved Instances**: Production databases
- **S3 Lifecycle**: Automated data lifecycle

### Monitoring Costs
- **CloudWatch**: Log retention policies
- **Data Transfer**: Optimized routing
- **Storage**: Appropriate storage classes 