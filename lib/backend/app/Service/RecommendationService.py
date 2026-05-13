from collections import defaultdict, deque
from core.database import db

class RecommendationService:
    def __init__(self):
        self.db = db

    async def get_recommendations(self, target_user_id: str):

        orders = await self.db.orders.find().to_list(length=1000)
        
        if not orders:
            return []
            
        
        graph = defaultdict(list)
        
        for order in orders:
            
            user_node = f"user_{order.get('customer_id')}"
            gig_node = f"gig_{order.get('gig_id')}"
            
            
            graph[user_node].append(gig_node)
            graph[gig_node].append(user_node)
            
        target_node = f"user_{target_user_id}"
        
        
        if target_node not in graph:
            return []
            
        #BFS Search  
        
        queue = deque([(target_node, 0)])
        visited = {target_node}
        
        
        used_services = set(graph[target_node])
        recommendations = set()
        
        # 4. Traverse the Graph
        while queue:
            current_node, level = queue.popleft()
            
            if level == 3:
                if current_node.startswith("gig_"):
                    
                    if current_node not in used_services:
                        
                        raw_gig_id = current_node.replace("gig_", "")
                        recommendations.add(raw_gig_id)
                
                continue
                
            if level > 3:
                
                continue
                
            
            for neighbor in graph[current_node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append((neighbor, level + 1))
                    
        return list(recommendations)
