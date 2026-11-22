import os
import random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance

# Seed for reproducible, high quality artistic layout
random.seed(42)
np.random.seed(42)

tiles_dir = "telecom_hakathon/assets/sprites/environment/outpost_tiles"
env_dir = "telecom_hakathon/assets/sprites/environment"

# Load base ground tiles
tile_p1 = Image.open(f"{tiles_dir}/tile_dirt_plain1.png").convert("RGBA")
tile_p2 = Image.open(f"{tiles_dir}/tile_dirt_plain2.png").convert("RGBA")
tile_leaves = Image.open(f"{tiles_dir}/tile_dirt_leaves.png").convert("RGBA")
tile_loam = Image.open(f"{tiles_dir}/tile_dirt_loam1.png").convert("RGBA")
tile_stones = Image.open(f"{tiles_dir}/tile_dirt_stones.png").convert("RGBA")
tile_ridge = Image.open(f"{tiles_dir}/tile_dirt_ridge.png").convert("RGBA")
tile_grass = Image.open(f"{tiles_dir}/tile_dirt_grass.png").convert("RGBA")
tile_corner = Image.open(f"{tiles_dir}/tile_dirt_corner.png").convert("RGBA")

ground_tiles = [
    (tile_p1, 0.28),
    (tile_p2, 0.25),
    (tile_leaves, 0.20),
    (tile_loam, 0.12),
    (tile_stones, 0.08),
    (tile_ridge, 0.04),
    (tile_grass, 0.03)
]

# Load road assets
road_cross = Image.open(f"{tiles_dir}/road_crossroad.png").convert("RGBA")
road_h = Image.open(f"{tiles_dir}/road_straight_h.png").convert("RGBA")
road_h2 = Image.open(f"{tiles_dir}/road_straight_h2.png").convert("RGBA")
road_v = Image.open(f"{tiles_dir}/road_straight_v.png").convert("RGBA")
road_curve = Image.open(f"{tiles_dir}/road_curve.png").convert("RGBA")

# Load props
prop_plate = Image.open(f"{tiles_dir}/prop_tower_mount_plate.png").convert("RGBA")
prop_pole = Image.open(f"{tiles_dir}/prop_tower_mount_pole.png").convert("RGBA")
prop_fence = Image.open(f"{tiles_dir}/prop_fence_barbed_wire.png").convert("RGBA")
prop_fence_broken = Image.open(f"{tiles_dir}/prop_fence_broken.png").convert("RGBA")
prop_wall_brick = Image.open(f"{tiles_dir}/prop_wall_brick.png").convert("RGBA")
prop_wall_ruin = Image.open(f"{tiles_dir}/prop_wall_brick_ruin.png").convert("RGBA")
prop_sandbags = Image.open(f"{tiles_dir}/prop_sandbags.png").convert("RGBA")
prop_barrier = Image.open(f"{tiles_dir}/prop_barrier_metal.png").convert("RGBA")

prop_boulder = Image.open(f"{tiles_dir}/prop_boulder_moss.png").convert("RGBA")
prop_barrels = Image.open(f"{tiles_dir}/prop_barrels_oil.png").convert("RGBA")
prop_crates = Image.open(f"{tiles_dir}/prop_crates_wood.png").convert("RGBA")
prop_scrap = Image.open(f"{tiles_dir}/prop_scrap_girders.png").convert("RGBA")

prop_tree = Image.open(f"{tiles_dir}/prop_tree_autumn.png").convert("RGBA")
prop_bush = Image.open(f"{tiles_dir}/prop_bush_autumn.png").convert("RGBA")
prop_reeds = Image.open(f"{tiles_dir}/prop_reeds_tall.png").convert("RGBA")
prop_dead_bush = Image.open(f"{tiles_dir}/prop_dead_bush.png").convert("RGBA")
prop_dead_tree = Image.open(f"{tiles_dir}/prop_dead_tree.png").convert("RGBA")
prop_grass = Image.open(f"{tiles_dir}/prop_grass_small.png").convert("RGBA")

MAP_W = 2816
MAP_H = 1536
TILE_S = 78

def generate_sector_map():
    print(f"Creating base canvas {MAP_W}x{MAP_H}...")
    canvas = Image.new("RGBA", (MAP_W, MAP_H), (52, 40, 30, 255))
    
    # 1. Fill ground with organic tiling
    cols = (MAP_W // TILE_S) + 2
    rows = (MAP_H // TILE_S) + 2
    
    tiles_pool = []
    for t, weight in ground_tiles:
        tiles_pool.extend([t] * int(weight * 100))
        
    for r in range(rows):
        for c in range(cols):
            t = random.choice(tiles_pool)
            # Random subtle rotation / flipping for natural look
            if random.random() < 0.25:
                t = t.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
            elif random.random() < 0.15:
                t = t.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
            canvas.paste(t, (c * TILE_S, r * TILE_S))
            
    # Add subtle soft noise / ground variation overlay
    noise_overlay = Image.new("RGBA", (MAP_W, MAP_H), (0, 0, 0, 0))
    draw_n = ImageDraw.Draw(noise_overlay)
    for _ in range(800):
        nx = random.randint(0, MAP_W)
        ny = random.randint(0, MAP_H)
        nr = random.randint(15, 65)
        # dark loam spots or light dust patches
        col = (35, 26, 18, random.randint(15, 45)) if random.random() < 0.6 else (120, 95, 65, random.randint(10, 25))
        draw_n.ellipse([nx - nr, ny - nr, nx + nr, ny + nr], fill=col)
    noise_overlay = noise_overlay.filter(ImageFilter.GaussianBlur(12))
    canvas.alpha_composite(noise_overlay)

    # 2. Road Network with Tire Tracks
    # The main access dirt road runs east-west and intersects at the center
    # Main horizontal road: Y ~ 860
    # Center tower is at (1408, 860)
    # Recycler is at (1050, 860)
    # Let's create an authentic dirt road connecting North, South, East, West to the Outpost
    
    # Horizontal road: from X=0 to X=MAP_W at Y=850
    # Stitched road segments:
    road_rw = road_h.width
    road_rh = road_h.height
    for rx in range(0, MAP_W, road_rw):
        # alternate between road_h and road_h2
        r_tile = road_h if (rx // road_rw) % 2 == 0 else road_h2
        canvas.alpha_composite(r_tile, (rx, 830))
        
    # Vertical road segment leading to the outpost from North (Y=0 to Y=830)
    # At X ~ 1408
    for ry in range(0, 830, road_v.height):
        canvas.alpha_composite(road_v, (1368, ry))
        
    # Vertical road segment leading South from the outpost (Y=890 to Y=MAP_H)
    for ry in range(890, MAP_H, road_v.height):
        canvas.alpha_composite(road_v, (1368, ry))
        
    # Secondary arterial road leading to the Recycler (X ~ 1050)
    for ry in range(300, 830, road_v.height):
        canvas.alpha_composite(road_v, (1010, ry))

    # 4-Way Crossroads at main junction (1368, 810)
    canvas.alpha_composite(road_cross, (1310, 760))
    # Junction at Recycler road (1010, 830)
    canvas.alpha_composite(road_cross, (950, 760))

    # Helper function to paste with center anchor
    def paste_prop(prop_img, center_x, center_y, scale=1.0, flip_h=False):
        sp = prop_img
        if flip_h:
            sp = sp.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        if scale != 1.0:
            nw = int(sp.width * scale)
            nh = int(sp.height * scale)
            sp = sp.resize((nw, nh), Image.Resampling.LANCZOS)
        px = int(center_x - sp.width // 2)
        py = int(center_y - sp.height // 2)
        canvas.alpha_composite(sp, (px, py))

    # 3. Central Telecom Tower Foundation (Vector2(1408, 860))
    # Bolted steel foundation pad with circular collar right at the tower position!
    paste_prop(prop_plate, 1408, 860, scale=1.35)
    
    # Sandbag defense bunker around the tower:
    # Front-left defense:
    paste_prop(prop_sandbags, 1260, 930, scale=0.85)
    # Front-right defense:
    paste_prop(prop_sandbags, 1556, 930, scale=0.85, flip_h=True)
    # North defensive barricade:
    paste_prop(prop_barrier, 1408, 730, scale=1.1)

    # Fortified brick walls protecting the rear:
    paste_prop(prop_wall_brick, 1408, 630, scale=0.9)
    paste_prop(prop_wall_ruin, 1580, 630, scale=0.9)
    paste_prop(prop_wall_ruin, 1236, 630, scale=0.9, flip_h=True)

    # 4. Recycling Depot & Crafting Station (Vector2(1050, 860))
    # Surrounding the Recycler:
    # Steel girders and scrap pile:
    paste_prop(prop_scrap, 930, 860, scale=1.1)
    paste_prop(prop_scrap, 1170, 870, scale=0.9, flip_h=True)
    
    # Wooden supply crates:
    paste_prop(prop_crates, 960, 950, scale=1.0)
    paste_prop(prop_crates, 1140, 950, scale=0.95, flip_h=True)
    
    # Rusty oil barrels:
    paste_prop(prop_barrels, 980, 780, scale=1.0)
    paste_prop(prop_barrels, 1120, 780, scale=1.0, flip_h=True)
    
    # Concrete / metal crowd barriers near crafting depot:
    paste_prop(prop_barrier, 1050, 990, scale=0.9)

    # 5. Outpost Perimeter Fortifications (Barbed Wire & Security Fences)
    # North perimeter fence line:
    for fx in [500, 860, 1950, 2310]:
        paste_prop(prop_fence, fx, 220, scale=0.9)
    # Broken fence section showing breach point:
    paste_prop(prop_fence_broken, 1040, 220, scale=0.9)
    paste_prop(prop_fence_broken, 1780, 220, scale=0.9, flip_h=True)

    # South perimeter fence line:
    for fx in [500, 860, 1950, 2310]:
        paste_prop(prop_fence, fx, 1340, scale=0.9)
    paste_prop(prop_fence_broken, 1040, 1340, scale=0.9)
    paste_prop(prop_fence_broken, 1780, 1340, scale=0.9, flip_h=True)

    # Flanking brick walls and sandbags around outpost choke points:
    paste_prop(prop_wall_brick, 700, 600, scale=0.85)
    paste_prop(prop_sandbags, 700, 680, scale=0.85)
    paste_prop(prop_wall_brick, 2116, 600, scale=0.85)
    paste_prop(prop_sandbags, 2116, 680, scale=0.85)
    
    paste_prop(prop_wall_brick, 700, 1120, scale=0.85)
    paste_prop(prop_sandbags, 700, 1040, scale=0.85)
    paste_prop(prop_wall_brick, 2116, 1120, scale=0.85)
    paste_prop(prop_sandbags, 2116, 1040, scale=0.85)

    # 6. Environmental Rocks, Boulders, and Debris
    boulder_positions = [
        (350, 420), (550, 380), (2250, 420), (2450, 380),
        (350, 1150), (580, 1220), (2250, 1150), (2480, 1220),
        (820, 820), (1980, 820), (1408, 1150), (1408, 480)
    ]
    for bx, by in boulder_positions:
        paste_prop(prop_boulder, bx, by, scale=random.uniform(0.8, 1.15), flip_h=random.choice([True, False]))

    # 7. Autumn Trees & Vegetation
    tree_positions = [
        # Northwest woods
        (180, 160), (320, 140), (220, 300), (380, 260), (120, 480),
        # Southwest woods
        (180, 1380), (320, 1400), (220, 1220), (380, 1260), (120, 1040),
        # Northeast woods
        (2636, 160), (2496, 140), (2596, 300), (2436, 260), (2696, 480),
        # Southeast woods
        (2636, 1380), (2496, 1400), (2596, 1220), (2436, 1260), (2696, 1040),
        # Mid-perimeter stands
        (650, 120), (1408, 100), (2166, 120),
        (650, 1440), (1408, 1460), (2166, 1440)
    ]
    # Sort by Y for correct top-to-bottom depth
    tree_positions.sort(key=lambda p: p[1])
    for tx, ty in tree_positions:
        if random.random() < 0.65:
            paste_prop(prop_tree, tx, ty, scale=random.uniform(1.2, 1.5))
        else:
            paste_prop(prop_dead_tree, tx, ty, scale=random.uniform(1.1, 1.4))

    # Dense autumn bushes and tall reeds around tree bases and perimeter
    for tx, ty in tree_positions:
        ox = tx + random.randint(-40, 40)
        oy = ty + random.randint(15, 35)
        paste_prop(random.choice([prop_bush, prop_reeds, prop_dead_bush]), ox, oy, scale=random.uniform(0.85, 1.2))

    # Small scattered weeds & grass tufts across the wasteland
    for _ in range(65):
        gx = random.randint(80, MAP_W - 80)
        gy = random.randint(60, MAP_H - 60)
        # Avoid road centers
        if abs(gy - 850) < 40:
            continue
        paste_prop(random.choice([prop_grass, prop_bush, prop_dead_bush]), gx, gy, scale=random.uniform(0.65, 0.95))

    return canvas

print("=== Generating New Outpost Arena Map ===")
sector_map_day = generate_sector_map()

# Save day sector map
map_day_path = f"{env_dir}/map_t4395k.png"
sector_map_day.convert("RGB").save(map_day_path, quality=95)
print(f"Saved Day Map: {map_day_path} ({MAP_W}x{MAP_H})")

# Generate Night Combat Edition (Atmospheric Dystopian Night)
# Convert colors: Shift warmth to cool nocturnal blue/cyan moonlight while preserving orange leaves/rust
def make_night_version(img):
    arr = np.array(img).astype(float)
    r = arr[:, :, 0]
    g = arr[:, :, 1]
    b = arr[:, :, 2]
    
    # Cool moonlight shift: boost blue, reduce green slightly, dampen red
    r_n = r * 0.42 + 10.0
    g_n = g * 0.54 + 18.0
    b_n = b * 0.85 + 32.0
    
    # Preserve glowing beacons/autumn highlights
    is_warm = (r > b + 25)
    r_n[is_warm] = r[is_warm] * 0.62 + 12.0
    g_n[is_warm] = g[is_warm] * 0.55 + 10.0
    b_n[is_warm] = b[is_warm] * 0.70 + 20.0
    
    out_arr = np.clip(np.dstack([r_n, g_n, b_n, arr[:, :, 3]]), 0, 255).astype(np.uint8)
    return Image.fromarray(out_arr)

sector_map_night = make_night_version(sector_map_day)
map_night_path = f"{env_dir}/metalslug_arena_night.png"
sector_map_night.save(map_night_path)
print(f"Saved Night Map: {map_night_path} ({MAP_W}x{MAP_H})")

sector_map_day.save(f"{env_dir}/metalslug_arena_day.png")
print("All maps generated successfully!")
