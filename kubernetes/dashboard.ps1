kubectl create -f "https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml"

# launch proxy in separate process
Start-Process kubectl "proxy"