printNode = (node, indent = 0) ->
  spaces = new Array(indent).join(' ')
  console.log(spaces + "[#{if node.leaf then "LEAF" else "BRANCH"} #{node.depth}]: [#{node.bounds[0]} #{node.bounds[2]}), [#{node.bounds[1]} #{node.bounds[3]})")
  console.log(spaces + "- #{id} @ (#{pos[0]} #{pos[1]} #{pos[2]} #{pos[3]})") for own id, pos of node.bigItems
  console.log(spaces + "- #{id} @ (#{pos[0]} #{pos[1]} #{pos[2]} #{pos[3]})") for own id, pos of node.items
  printNode(child, indent + 1) for own child in node.children

printTree = (tree) ->
  printNode(tree.root, 0)