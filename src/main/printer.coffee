printNode = (node, ret, indent = 0) ->
  printOneNode(node, ret, indent)
  printNode(child, ret, indent + 1) for child in node.children
  ret

printOneNode = (node, ret, indent = 0) ->
  indent = new Array(indent).join('-')
  ret.push(indent + "[#{if node.leaf then "LEAF" else "BRANCH"} #{node.depth}]: [#{node.bounds[0]} #{node.bounds[2]}), [#{node.bounds[1]} #{node.bounds[3]}) {#{node.numItems}}")
  ret.push(indent + "BI #{id}") for own id of node.bigItems
  ret.push(indent + "I  #{id}") for own id of node.items
  ret

printTree = (tree) ->
  printNode(tree.root, [], 0)

logTree = (tree) ->
  console.log(line) for line in printTree(tree)