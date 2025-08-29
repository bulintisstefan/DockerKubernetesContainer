Hello-KS – Docker + Kubernetes (Rancher Desktop)

Aplicație Flask Hello World containerizată cu Docker și rulată pe un cluster Kubernetes local (Rancher Desktop).
Testare acces prin kubectl port-forward.

Cuprins

Structură

Cerințe

Rulare locală (opțional)

Build Docker

Rulare în Docker

Deploy în Kubernetes

Testare

Curățare

Troubleshooting

Notițe

Structură

hello-ks/

├─ app.py

├─ requirements.txt

├─ Dockerfile

└─ k8s/

   ├─ deployment.yaml
   
   └─ service.yaml

Fișiere cheie

app.py – Flask app (HTTP pe port 8080), endpoint-uri GET / și GET /healthz.

Dockerfile – construiește imaginea hello-ks:1.0.

k8s/deployment.yaml – Deployment cu 1 replică, imagePullPolicy: Never, readiness/liveness probes pe /healthz.

k8s/service.yaml – Service ClusterIP care mapează 8081 -> targetPort 8080.

Cerințe

Rancher Desktop (Kubernetes Enabled). La mine rulează cu CE: moby (dockerd).

kubectl disponibil în shell.

(WSL + Windows) – kubeconfig la ~/.kube/config setat pe contextul rancher-desktop.

Verificare rapidă:

kubectl config use-context rancher-desktop
kubectl cluster-info

Rulare locală (opțional)
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python app.py
# http://localhost:8080

Build Docker

Important (Windows/WSL): fă build-ul cu daemonul Docker folosit de Rancher Desktop (dockerd/moby).
Dacă ești în Windows:

cd C:\Users\<user>\hello-ks
docker build -t hello-ks:1.0 .
docker images | findstr hello-ks


Dacă ești în WSL și vrei să construiești din Windows fără a copia fișierele:

cd "\\wsl$\Ubuntu\home\<user>\hello-ks"
docker build -t hello-ks:1.0 .

Rulare în Docker
docker run --rm -p 8080:8080 hello-ks:1.0
# http://localhost:8080  |  /healthz

Deploy în Kubernetes

Pentru test local, deployment-ul folosește imagePullPolicy: Never ca să ia imaginea locală.

Aplică manifestele:

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

kubectl get pods -w
kubectl get svc hello-ks

Testare

Forward portul Service-ului la mașina locală:

kubectl port-forward svc/hello-ks 8081:8081


În alt terminal / browser:

curl http://localhost:8081/healthz   # → ok
curl http://localhost:8081/          # → JSON “Hello from Flask…”

Curățare
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
# (opțional) docker rmi hello-ks:1.0

Troubleshooting
ErrImagePull / ImagePullBackOff

Kubernetes încearcă să tragă imaginea din registry public. Pentru test local:

asigură-te că imaginea exista în daemonul Docker al Rancher Desktop (docker images | grep hello-ks);

păstrează image: hello-ks:1.0 și imagePullPolicy: Never în deployment.yaml;

redeploy:

kubectl delete -f k8s/deployment.yaml
kubectl apply  -f k8s/deployment.yaml

ErrImageNeverPull

Imaginea nu există în daemonul văzut de cluster:

fă docker build -t hello-ks:1.0 . folosind Docker-ul Rancher Desktop (dockerd/moby) din Windows/PowerShell (sau prin \\wsl$).

apoi kubectl rollout restart deploy/hello-ks.

kubectl folosește 127.0.0.1:8080

Kubeconfig lipsă/incorect. Copiază config-ul Rancher Desktop la:

~/.kube/config
# (Windows) C:\Users\<user>\.kube\config   → în WSL: /mnt/c/Users/<user>/.kube/config

Probes eșuează

Verifică logurile:

kubectl logs deploy/hello-ks


Asigură-te că app-ul ascultă pe :8080, /healthz răspunde cu 200.
