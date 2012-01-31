printNode = (node, indent = 0) ->
  if node.leaf
    console.log(SPACES[indent] + "[LEAF #{node.level}]: [#{node.minX} #{node.maxX}), [#{node.minY} #{node.maxY})")
    console.log(SPACES[indent] + "  #{id} @ (#{pos[0]} #{pos[1]} #{pos[2]} #{pos[3]})") for own id, pos of node.items
  else
    console.log(SPACES[indent] + "[BRANCH #{node.level}]: [#{node.minX} #{node.maxX}), [#{node.minY} #{node.maxY})")
  printNode(child, indent + 1) for own child in node.children

printTree = (tree) ->
  printNode(tree.root, 0)