printNode = (node, indent = 0) ->
  return if indent > 10 #TODO: shouldn't need this
  printOneNode(node, indent)
  printNode(child, indent + 1) for own child in node.children

printOneNode = (node, indent = 0) ->
  spaces = new Array(indent).join(' ')
  console.log(spaces + "[#{if node.leaf then "LEAF" else "BRANCH"} #{node.depth}]: [#{node.bounds[0]} #{node.bounds[2]}), [#{node.bounds[1]} #{node.bounds[3]}) {#{node.numItems}}")
  console.log(spaces + "BI #{id} @ (#{pos[0]} #{pos[1]} #{pos[2]} #{pos[3]})") for own id, pos of node.bigItems
  console.log(spaces + "I  #{id} @ (#{pos[0]} #{pos[1]} #{pos[2]} #{pos[3]})") for own id, pos of node.items

printTree = (tree) ->
  printNode(tree.root, 0)