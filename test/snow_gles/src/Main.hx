import snow.api.Debug.*;
import snow.types.Types;
import snow.modules.opengl.GL;
import haxe.io.UInt8Array;
// import snow.systems.assets.Asset;
// import snow.systems.assets.AssetBytes;

import nanovg.Nvg;
using cpp.NativeString;

typedef UserConfig = {}

@:log_as('app')
class Main extends snow.App {
    
    var font:Int;
    var fontBold: Int;
    var vg:cpp.Pointer<NvgContext>;
    var linearGradient:NvgPaint;
    var count:Int;

    function new() {}

    override function config( config:AppConfig ) : AppConfig {

        config.window.title = 'linc nanovg gles example';

            //currently required for GLES3.x
        config.render.opengl.profile = gles;

            //required for nanovg
        config.render.stencil = 8;
        config.render.depth = 24;

        return config;

    } //config

    override function ready() {

        log('ready');

        trace('OpenGL version: ${GL.versionString()}');

        vg = Nvg.createGL(NvgMode.ANTIALIAS|NvgMode.STENCIL_STROKES);

        this.count = 0;

        var fontP = app.assets.bytes("assets/DroidSans.ttf");
        var fontBoldP = app.assets.bytes("assets/DroidSansBold.ttf");

        snow.api.Promise.all([
            fontP,
            fontBoldP
        ]).then(function(b:Array<AssetBytes>){
            font = Nvg.createFontMem(vg, "arial", cpp.Pointer.ofArray(b[0].bytes.buffer), b[0].bytes.length, 1);
            fontBold = Nvg.createFontMem(vg, "arial-bold", cpp.Pointer.ofArray(b[1].bytes.buffer), b[1].bytes.length, 1);
        });


    } //ready

    override function onkeyup( keycode:Int, _,_, mod:ModState, _,_ ) {

        if( keycode == Key.escape ) {
            app.shutdown();
        }

    } //onkeyup

    function drawPage(){
  
            //Handling high DPI:
            //- glViewport takes backing renderable size (render_w/_h)
            //- our app wants window sized coordinates (window_w/_h)
            //- snow gives us backing size, we convert for our needs
            //- nanovg takes window size + ratio, easy!

        var dpr = app.runtime.window_device_pixel_ratio();

        #if ios
            dpr = 1.0;
        #end

        //trace('DPR: ${dpr}');

        var render_w = app.runtime.window_width();
        var render_h = app.runtime.window_height();
        var window_width = Math.floor(render_w/dpr);
        var window_height = Math.floor(render_h/dpr);

        GL.viewport(0, 0, render_w, render_h);
        GL.clearColor (0.3,0.3,0.3, 0.7);
        GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT | GL.STENCIL_BUFFER_BIT);
        GL.enable(GL.BLEND);
        GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		GL.enable(GL.CULL_FACE);
		GL.disable(GL.DEPTH_TEST);


        Nvg.beginFrame(vg, window_width, window_height, dpr);

        Nvg.save(vg);

        // Drop shadow
        var shadowPaint = Nvg.boxGradient(vg, -3, -3, window_width+20, 130, 0, 10, Nvg.rgba(0,0,0, 100), Nvg.rgba(0,0,0,0));
        Nvg.beginPath(vg);
        Nvg.rect(vg, 0, 0, window_width, 120+30);
        //Nvg.roundedRect(vg, 0, 0, window_width, 120, cornerRadius);
        Nvg.pathWinding(vg, NvgSolidity.HOLE);
        Nvg.fillPaint(vg, shadowPaint);
        Nvg.fill(vg);   

        linearGradient = Nvg.linearGradient(vg, 100, 180, 100, 120, Nvg.rgba(0, 0, 0, 50), Nvg.rgba(0, 0, 0, 80));
        Nvg.beginPath(vg);
        Nvg.rect(vg, 0, 0, window_width, 120);
        Nvg.fillColor(vg, Nvg.rgba(28,30,34,192));
        // Nvg.roundedRect(vg, 0, 0, window_width, 120, 8);
        Nvg.fillPaint(vg, linearGradient);
        Nvg.fill(vg);              

        
        // Nvg.fontFaceId(vg, font);
        // Nvg.fillColor(vg, Nvg.rgba(255,0,0,255));
        // Nvg.text(vg, 100, 50, "This is some text", null);

        Nvg.fontSize(vg, 50.0);
        Nvg.fontFaceId(vg, fontBold);
        Nvg.fillColor(vg, Nvg.rgba(255,255,255, 192));
        Nvg.textAlign(vg, NvgAlign.ALIGN_CENTER|NvgAlign.ALIGN_MIDDLE);
        Nvg.text(vg, Math.floor(window_width/2), 60, "Home", null);
       


        var footerLinearGradient = Nvg.linearGradient(vg, 100, window_height-120+180, 100, 120, Nvg.rgba(0, 0, 255, 80), Nvg.rgba(0, 0, 255, 192));
        Nvg.beginPath(vg);
        Nvg.rect(vg, 0, window_height-120, window_width, 120);
        Nvg.fillColor(vg, Nvg.rgba(0, 0, 255, 255));
        // Nvg.roundedRect(vg, 0, 0, window_width, 120, 8);
        Nvg.fillPaint(vg, footerLinearGradient);
        Nvg.fill(vg);


        Nvg.fontSize(vg, 50.0);
        Nvg.fontFaceId(vg, font);
        Nvg.fillColor(vg, Nvg.rgba(255,255,255, 192));
        Nvg.textAlign(vg, NvgAlign.ALIGN_CENTER|NvgAlign.ALIGN_MIDDLE);
        Nvg.text(vg, Math.floor(window_width/2), (window_height-60), "Play", null);     

        Nvg.endFrame(vg); 
    }

     override function tick( delta:Float ) {
        drawPage();
     } //update

} //Main
