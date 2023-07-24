# Drain Cordon/Uncordon

#
# Cordon: 
# If we apply Cordon to a node, it will prevent any pods from being scheduled onto the node.
# Already running pods will not be affected and will remain accessible.
kubectl cordon worker-1


# Drain : 
# If we drain a node, it will evict the pods, causing them to be rescheduled onto other nodes.
# Pods will be terminated gracefully and rescheduled onto other nodes.
kubectl drain --ignore-daemonsets worker-1

#
#
# Uncordon:
# If we drain or cordon a node, we can use the 'uncordon' command to restore the node for scheduling
kubectl uncordon worker-1