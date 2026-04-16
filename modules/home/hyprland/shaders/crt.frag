precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

vec2 curve(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    vec2 offset = abs(uv.yx) / vec2(6.0, 4.0);
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;
    return uv;
}

vec4 scanline(float x, float y, vec4 col) {
    float scanIntensity = 0.12;
    float scan = sin(y * 6.2831853 * 240.0) * scanIntensity;
    col.rgb -= scan;
    return col;
}

void main() {
    vec2 uv = curve(v_texcoord);
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec4 col = texture2D(tex, uv);

    float x = uv.x;
    float y = uv.y;

    // scanlines
    col = scanline(x, y, col);

    // vignette
    float vignette = 1.0 - 0.3 * length((v_texcoord - 0.5) * 1.2);
    col.rgb *= vignette;

    // slight color fringing (chromatic aberration)
    float fringe = 0.001;
    col.r = texture2D(tex, vec2(uv.x - fringe, uv.y)).r;
    col.b = texture2D(tex, vec2(uv.x + fringe, uv.y)).b;

    // slight brightness boost to compensate
    col.rgb *= 1.05;

    gl_FragColor = col;
}