extends Node3D

var score_home := 0
var score_away := 0
var selected := 0
var players = [
    {"name":"Ola Kade","country":"Nigeria","pos":"ST","rating":92,"tier":"PURPLE"},
    {"name":"Kylian Maba","country":"France","pos":"LW","rating":91,"tier":"PINK"},
    {"name":"Leo Messa","country":"Argentina","pos":"CAM","rating":90,"tier":"GOLD"},
    {"name":"Cristo Rado","country":"Portugal","pos":"RW","rating":90,"tier":"GOLD"},
    {"name":"Victor Osara","country":"Nigeria","pos":"ST","rating":89,"tier":"RED"},
    {"name":"Jude Bellor","country":"England","pos":"CM","rating":88,"tier":"RED"},
    {"name":"Ayo Balog","country":"Nigeria","pos":"CB","rating":86,"tier":"BLUE"},
    {"name":"Tariq Sane","country":"USA","pos":"LB","rating":84,"tier":"BLUE"},
    {"name":"Mika Duran","country":"Brazil","pos":"RB","rating":87,"tier":"GOLD"},
    {"name":"Samuel Kobi","country":"Ghana","pos":"CM","rating":85,"tier":"BLUE"},
    {"name":"David Okoro","country":"Nigeria","pos":"GK","rating":88,"tier":"RED"},
]

var title_label: Label
var score_label: Label
var info_label: Label
var card_panel: Panel
var card_label: Label
var field: Node3D
var ball: MeshInstance3D
var player_nodes: Array[Node3D] = []
var ball_velocity := Vector3.ZERO
var active_match := false

func _ready():
    build_world()
    build_ui()
    show_home()

func build_world():
    var env = WorldEnvironment.new()
    var environment = Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#081b2a")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#b8d8ff")
    environment.ambient_light_energy = 0.8
    env.environment = environment
    add_child(env)

    var light = DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-55,-25,0)
    light.light_energy = 1.2
    add_child(light)

    field = Node3D.new()
    add_child(field)

    var ground = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(42,26)
    ground.mesh = plane
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color("#176b36")
    ground.material_override = mat
    field.add_child(ground)

    # pitch markings
    for x in [-21.0,21.0]:
        add_line(Vector3(x,0.03,-13), Vector3(x,0.03,13))
    add_line(Vector3(0,0.04,-13), Vector3(0,0.04,13))
    add_line(Vector3(-21,0.04,-13), Vector3(21,0.04,-13))
    add_line(Vector3(-21,0.04,13), Vector3(21,0.04,13))

    create_ball()
    create_team()

func add_line(a:Vector3,b:Vector3):
    var mi=MeshInstance3D.new()
    var box=BoxMesh.new()
    box.size=Vector3(0.08,0.02,a.distance_to(b))
    mi.mesh=box
    mi.position=(a+b)/2.0
    mi.look_at(b,Vector3.UP)
    var mat=StandardMaterial3D.new()
    mat.albedo_color=Color.WHITE
    mi.material_override=mat
    field.add_child(mi)

func create_ball():
    ball=MeshInstance3D.new()
    var sphere=SphereMesh.new()
    sphere.radius=0.32
    sphere.height=0.64
    ball.mesh=sphere
    ball.position=Vector3(0,0.35,0)
    var mat=StandardMaterial3D.new()
    mat.albedo_color=Color.WHITE
    ball.material_override=mat
    field.add_child(ball)

func create_team():
    var positions=[
        Vector3(-15,0.65,0), Vector3(-10,0.65,-7), Vector3(-8,0.65,7),
        Vector3(-6,0.65,-3), Vector3(-6,0.65,3), Vector3(-2,0.65,-9),
        Vector3(-2,0.65,9), Vector3(2,0.65,-4), Vector3(4,0.65,4),
        Vector3(7,0.65,-2), Vector3(7,0.65,2)
    ]
    for i in range(11):
        var p=Node3D.new()
        p.position=positions[i]
        field.add_child(p)
        var body=MeshInstance3D.new()
        var capsule=CapsuleMesh.new()
        capsule.radius=0.35
        capsule.height=1.35
        body.mesh=capsule
        var mat=StandardMaterial3D.new()
        mat.albedo_color=Color("#18a0ff") if i != 10 else Color("#ffd21f")
        body.material_override=mat
        p.add_child(body)
        player_nodes.append(p)

func build_ui():
    var layer=CanvasLayer.new()
    add_child(layer)
    title_label=Label.new()
    title_label.position=Vector2(40,25)
    title_label.add_theme_font_size_override("font_size",34)
    title_label.text="OLAMILEKAN FOOTBALL"
    layer.add_child(title_label)

    score_label=Label.new()
    score_label.position=Vector2(530,25)
    score_label.add_theme_font_size_override("font_size",30)
    layer.add_child(score_label)

    info_label=Label.new()
    info_label.position=Vector2(40,660)
    info_label.add_theme_font_size_override("font_size",18)
    layer.add_child(info_label)

    card_panel=Panel.new()
    card_panel.position=Vector2(950,90)
    card_panel.size=Vector2(290,420)
    layer.add_child(card_panel)

    card_label=Label.new()
    card_label.position=Vector2(25,25)
    card_label.add_theme_font_size_override("font_size",20)
    card_panel.add_child(card_label)

    var start=Button.new()
    start.text="PLAY 11v11 MATCH"
    start.position=Vector2(40,85)
    start.size=Vector2(250,55)
    start.pressed.connect(start_match)
    layer.add_child(start)

    var roster=Button.new()
    roster.text="PLAYER CARDS"
    roster.position=Vector2(40,150)
    roster.size=Vector2(250,55)
    roster.pressed.connect(show_roster)
    layer.add_child(roster)

    var multiplayer=Button.new()
    multiplayer.text="ONLINE MULTIPLAYER (NEXT)"
    multiplayer.position=Vector2(40,215)
    multiplayer.size=Vector2(250,55)
    multiplayer.pressed.connect(show_online)
    layer.add_child(multiplayer)

    var voice=Button.new()
    voice.text="VOICE CHAT (NEXT)"
    voice.position=Vector2(40,280)
    voice.size=Vector2(250,55)
    voice.pressed.connect(show_voice)
    layer.add_child(voice)

func show_home():
    active_match=false
    score_label.text="HOME  0  -  0  AWAY"
    info_label.text="Original fictional players • Male footballers • No real-player likenesses"
    card_label.text="TEAM\n\nOLAMILEKAN FC\n\n11 Players\n\nNext: online matches + voice chat"
    for p in player_nodes: p.visible=false
    ball.visible=false

func start_match():
    active_match=true
    score_home=0
    score_away=0
    score_label.text="OLAMILEKAN FC  0  -  0  RIVALS FC"
    info_label.text="WASD = move • SPACE = pass • F = shoot"
    card_label.text="MATCH MODE\n\n11 vs 11\n\nCaptain: Ola Kade\nRating: 92\n\nUse F to shoot!"
    for p in player_nodes: p.visible=true
    ball.visible=true

func show_roster():
    active_match=false
    ball.visible=false
    for p in player_nodes: p.visible=false
    var s="PLAYER CARDS\n\n"
    for p in players:
        s += "%s  |  %s  |  %s  |  %d\n" % [p.name,p.country,p.pos,p.rating]
    card_label.text=s
    info_label.text="Fictional names are used so the game can be developed without real-player licensing."

func show_online():
    card_label.text="ONLINE MULTIPLAYER\n\nREADY FOR BACKEND\n\n• Matchmaking\n• Lagos vs Kaduna\n• Real-time 1v1/2v2\n• Accounts & saved progress\n\nServer integration is the next development stage."
    info_label.text="Online multiplayer requires a real-time game server."

func show_voice():
    card_label.text="LIVE VOICE CHAT\n\nREADY FOR INTEGRATION\n\n• Mute / unmute\n• Match voice channel\n• Push-to-talk option\n• Player volume control\n\nVoice service will be connected in the online stage."
    info_label.text="Voice chat requires a WebRTC/voice service."

func _process(delta):
    if not active_match: return
    var dir=Vector3.ZERO
    if Input.is_action_pressed("move_left"): dir.x-=1
    if Input.is_action_pressed("move_right"): dir.x+=1
    if Input.is_action_pressed("move_up"): dir.z-=1
    if Input.is_action_pressed("move_down"): dir.z+=1
    if dir.length()>0:
        player_nodes[0].position += dir.normalized()*delta*6.0
        player_nodes[0].position.x=clamp(player_nodes[0].position.x,-19.0,19.0)
        player_nodes[0].position.z=clamp(player_nodes[0].position.z,-11.0,11.0)
    ball.position=ball.position.lerp(player_nodes[0].position+Vector3(0,0.1,1.0),delta*8.0)
    if Input.is_action_just_pressed("shoot_ball"):
        score_home += 1
        score_label.text="OLAMILEKAN FC  %d  -  %d  RIVALS FC" % [score_home,score_away]
        info_label.text="GOOOAL! Great finish by Ola Kade!"
