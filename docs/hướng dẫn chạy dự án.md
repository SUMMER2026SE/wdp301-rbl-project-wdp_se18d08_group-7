# Setup Local: K8s + Kafka + Prometheus + ArgoCD

## 1. Yêu cầu
- Docker Desktop, Minikube, kubectl, Helm, Node.js, NestJS CLI.

## 2. Start Cluster
```bash
minikube start --memory=4096 --cpus=4
```

## 3. Cài đặt hạ tầng (Helm)
**Namespace & Thêm Repo:**
```bash
kubectl create ns argocd && helm repo add argo https://argoproj.github.io/argo-helm
kubectl create ns kafka && helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl create ns monitoring && helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```
**Install Services:**
```bash
helm install argocd argo/argo-cd -n argocd
helm install my-kafka bitnami/kafka -n kafka
helm install my-prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

## 4. Port-forward (Mở port ra localhost)
*(Giữ Terminal chạy ngầm - Mỗi lệnh 1 tab)*
- **Kafka**: `kubectl port-forward svc/my-kafka -n kafka 9092:9092`
- **Prometheus**: `kubectl port-forward svc/my-prometheus-kube-prometheus-prometheus -n monitoring 9090:9090`
- **ArgoCD**: `kubectl port-forward svc/argocd-server -n argocd 8080:443` 
*(Pass Argo: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`)*

## 5. Chạy Backend
- **Config**: Đổi Kafka broker thành `localhost:9092` trong source NestJS.
```bash
cd backend && npm install
npm run start:dev api-gateway
npm run start:dev auth-service
```

## 6. Daily Task
- **Làm việc**: `minikube start` -> Chạy lại `port-forward` Kafka/Prometheus.
- **Nghỉ làm**: `minikube stop` (Giải phóng RAM).
