#1. Describe a node and check predefined labels​
k describe node worker-1
k label nodes worker-1 --list

#2. List nodes with labels​
k get nodes --show-labels

#3. Create a label for a node​
k label nodes worker-1 node-name=worker-1

k label nodes worker-1 disktype=ssd

#4. Remove a label from a node​
k label nodes worker-1 disktype-










