/* ***** BEGIN LICENSE BLOCK *****
 * This file is part of Natron <http://www.natron.fr/>,
 * Copyright (C) 2016 INRIA and Alexandre Gauthier-Foichat
 *
 * Natron is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Natron is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Natron.  If not, see <http://www.gnu.org/licenses/gpl-2.0.html>
 * ***** END LICENSE BLOCK ***** */


#include "OSGLContext_mac.h"

#include <stdexcept>
#ifdef __NATRON_OSX__

#include <QDebug>
#include "Engine/OSGLContext.h"

NATRON_NAMESPACE_ENTER;

#if 0
void
OSGLContext_mac::createWindow()
{
    /*_nsWindow.delegate = [[GLFWWindowDelegate alloc] initWithGlfwWindow:window];
    if (window->ns.delegate == nil)
    {
        _glfwInputError(GLFW_PLATFORM_ERROR,
                        "Cocoa: Failed to create window delegate");
        return GLFW_FALSE;
    }*/

    const int width = 32;
    const int height = 32;

    NSRect contentRect = NSMakeRect(0, 0, width, height);

    _nsWindow.object = [[GLFWWindow alloc]
                         initWithContentRect:contentRect
                         styleMask:getStyleMask(window)
                         backing:NSBackingStoreBuffered
                         defer:NO];

    if (_nsWindow.object == nil) {
        throw std::runtime_error("Cocoa: Failed to create window");
    }

    [_nsWindow.object center];

    _nsWindow.view = [[GLFWContentView alloc] initWithGlfwWindow:window];

//#if defined(_GLFW_USE_RETINA)
    [_nsWindow.view setWantsBestResolutionOpenGLSurface:YES];
//#endif /*_GLFW_USE_RETINA*/

    [_nsWindow.object makeFirstResponder:_nsWindow.view];
    //[_nsWindow.object setDelegate:window->ns.delegate];
    [_nsWindow.object setContentView:_nsWindow.view];
    [_nsWindow.object setRestorable:NO];

}
#endif

static void makeAttribsFromFBConfig(const FramebufferConfig& pixelFormatAttrs, int major, int /*minor*/, bool coreProfile, int rendererID ,std::vector<CGLPixelFormatAttribute> &attributes)
{
    // See https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CGL_OpenGL/#//apple_ref/c/tdef/CGLPixelFormatAttribute
    // for a reference to attributes
    /*
     * The program chose a config based on the fbconfigs or visuals.
     * Those are based on the attributes from CGL, so we probably
     * do want the closest match for the color, depth, and accum.
     */
    if (rendererID != -1) {
        attributes.push_back(kCGLPFARendererID);
        attributes.push_back((CGLPixelFormatAttribute)rendererID);
    }
    attributes.push_back(kCGLPFAClosestPolicy);
    attributes.push_back(kCGLPFAAccelerated);
    attributes.push_back(kCGLPFAOpenGLProfile);
    if (coreProfile) {
        attributes.push_back((CGLPixelFormatAttribute) kCGLOGLPVersion_3_2_Core);
    } else {
        attributes.push_back((CGLPixelFormatAttribute) kCGLOGLPVersion_Legacy);
    }
    if (pixelFormatAttrs.doublebuffer) {
        attributes.push_back(kCGLPFADoubleBuffer);
    }
    /*if (pixelFormatAttrs.stereo) {
     attributes.push_back(kCGLPFAStereo);
     }*/

    if (major <= 2) {
        if (pixelFormatAttrs.auxBuffers && pixelFormatAttrs.auxBuffers != FramebufferConfig::ATTR_DONT_CARE) {
            attributes.push_back(kCGLPFAAuxBuffers);
            attributes.push_back((CGLPixelFormatAttribute)pixelFormatAttrs.auxBuffers);
        }
        if (pixelFormatAttrs.accumRedBits != FramebufferConfig::ATTR_DONT_CARE &&
            pixelFormatAttrs.accumGreenBits != FramebufferConfig::ATTR_DONT_CARE &&
            pixelFormatAttrs.accumBlueBits != FramebufferConfig::ATTR_DONT_CARE &&
            pixelFormatAttrs.accumAlphaBits != FramebufferConfig::ATTR_DONT_CARE)
        {
            const int accumBits = pixelFormatAttrs.accumRedBits +
            pixelFormatAttrs.accumGreenBits +
            pixelFormatAttrs.accumBlueBits +
            pixelFormatAttrs.accumAlphaBits;

            attributes.push_back(kCGLPFAAccumSize);
            attributes.push_back((CGLPixelFormatAttribute)accumBits);

        }

        /*
         Deprecated in OS X v10.7. This attribute must not be specified if the attributes array also requests a profile other than a legacy OpenGL profile; if present, pixel format creation fails.
         */

        //attributes.push_back(kCGLPFAOffScreen);
    }
    if (pixelFormatAttrs.redBits != FramebufferConfig::ATTR_DONT_CARE &&
        pixelFormatAttrs.greenBits != FramebufferConfig::ATTR_DONT_CARE &&
        pixelFormatAttrs.blueBits != FramebufferConfig::ATTR_DONT_CARE) {

        int colorBits = pixelFormatAttrs.redBits +
        pixelFormatAttrs.greenBits +
        pixelFormatAttrs.blueBits;

        // OS X needs non-zero color size, so set reasonable values
        if (colorBits == 0)
            colorBits = 24;
        else if (colorBits < 15)
            colorBits = 15;

        attributes.push_back(kCGLPFAColorSize);
        attributes.push_back((CGLPixelFormatAttribute)colorBits);
    }


    if (pixelFormatAttrs.alphaBits != FramebufferConfig::ATTR_DONT_CARE) {
        attributes.push_back(kCGLPFAAlphaSize);
        attributes.push_back((CGLPixelFormatAttribute)pixelFormatAttrs.alphaBits);
    }

    if (pixelFormatAttrs.depthBits != FramebufferConfig::ATTR_DONT_CARE) {
        attributes.push_back(kCGLPFADepthSize);
        attributes.push_back((CGLPixelFormatAttribute)pixelFormatAttrs.depthBits);
    }

    if (pixelFormatAttrs.stencilBits != FramebufferConfig::ATTR_DONT_CARE) {
        attributes.push_back(kCGLPFAStencilSize);
        attributes.push_back((CGLPixelFormatAttribute)pixelFormatAttrs.stencilBits);
    }

    // Use float buffers
    attributes.push_back(kCGLPFAColorFloat);

    if (pixelFormatAttrs.samples != FramebufferConfig::ATTR_DONT_CARE) {
        if (pixelFormatAttrs.samples == 0) {
            attributes.push_back(kCGLPFASampleBuffers);
            attributes.push_back((CGLPixelFormatAttribute)0);
        } else {
            attributes.push_back(kCGLPFAMultisample);
            attributes.push_back(kCGLPFASampleBuffers);
            attributes.push_back((CGLPixelFormatAttribute)1);
            attributes.push_back(kCGLPFASamples);
            attributes.push_back((CGLPixelFormatAttribute)pixelFormatAttrs.samples);
        }
    }
    attributes.push_back((CGLPixelFormatAttribute)0);

}

OSGLContext_mac::OSGLContext_mac(const FramebufferConfig& pixelFormatAttrs,int major, int minor,bool coreProfile, int rendererID, const OSGLContext_mac* shareContext)
: _context(0)
{




    std::vector<CGLPixelFormatAttribute> attributes;
    makeAttribsFromFBConfig(pixelFormatAttrs, major, minor, coreProfile, rendererID, attributes);

    CGLPixelFormatObj nativePixelFormat;
    GLint num; // stores the number of possible pixel formats
    CGLError errorCode = CGLChoosePixelFormat( &attributes[0], &nativePixelFormat, &num );
    if (errorCode != kCGLNoError) {
        throw std::runtime_error("CGL: Failed to choose pixel format");
    }

    errorCode = CGLCreateContext( nativePixelFormat, shareContext ? shareContext->_context : 0, &_context ); 
    if (errorCode != kCGLNoError) {
        throw std::runtime_error("CGL: Failed to create context");
    }
    CGLDestroyPixelFormat( nativePixelFormat );

    //errorCode = CGLSetCurrentContext( context );

#if 0
    unsigned int attributeCount = 0;

    // Context robustness modes (GL_KHR_robustness) are not yet supported on
    // OS X but are not a hard constraint, so ignore and continue

    // Context release behaviors (GL_KHR_context_flush_control) are not yet
    // supported on OS X but are not a hard constraint, so ignore and continue

#define ADD_ATTR(x) { attributes[attributeCount++] = x; }
#define ADD_ATTR2(x, y) { ADD_ATTR(x); ADD_ATTR(y); }

    // Arbitrary array size here
    NSOpenGLPixelFormatAttribute attributes[40];

    ADD_ATTR(NSOpenGLPFAAccelerated);
    ADD_ATTR(NSOpenGLPFAClosestPolicy);

#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    if (major >= 4) {
        ADD_ATTR2(NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion4_1Core);
    } else
#endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/
    {
        if (major >= 3) {
            ADD_ATTR2(NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core);
        }
    }

    if (major <= 2) {
        if (pixelFormatAttrs.auxBuffers != FramebufferConfig::ATTR_DONT_CARE)
            ADD_ATTR2(NSOpenGLPFAAuxBuffers, pixelFormatAttrs.auxBuffers);

        if (pixelFormatAttrs.accumRedBits != FramebufferConfig::ATTR_DONT_CARE &&
            pixelFormatAttrs.accumGreenBits != FramebufferConfig::ATTR_DONT_CARE &&
            pixelFormatAttrs.accumBlueBits != FramebufferConfig::ATTR_DONT_CARE &&
            pixelFormatAttrs.accumAlphaBits != FramebufferConfig::ATTR_DONT_CARE)
        {
            const int accumBits = pixelFormatAttrs.accumRedBits +
            pixelFormatAttrs.accumGreenBits +
            pixelFormatAttrs.accumBlueBits +
            pixelFormatAttrs.accumAlphaBits;

            ADD_ATTR2(NSOpenGLPFAAccumSize, accumBits);
        }
    }

    if (pixelFormatAttrs.redBits != FramebufferConfig::ATTR_DONT_CARE &&
        pixelFormatAttrs.greenBits != FramebufferConfig::ATTR_DONT_CARE &&
        pixelFormatAttrs.blueBits != FramebufferConfig::ATTR_DONT_CARE) {
        int colorBits = pixelFormatAttrs.redBits +
        pixelFormatAttrs.greenBits +
        pixelFormatAttrs.blueBits;

        // OS X needs non-zero color size, so set reasonable values
        if (colorBits == 0)
            colorBits = 24;
        else if (colorBits < 15)
            colorBits = 15;

        ADD_ATTR2(NSOpenGLPFAColorSize, colorBits);
    }

    if (pixelFormatAttrs.alphaBits != FramebufferConfig::ATTR_DONT_CARE)
        ADD_ATTR2(NSOpenGLPFAAlphaSize, pixelFormatAttrs.alphaBits);

    if (pixelFormatAttrs.depthBits != FramebufferConfig::ATTR_DONT_CARE)
        ADD_ATTR2(NSOpenGLPFADepthSize, pixelFormatAttrs.depthBits);

    if (pixelFormatAttrs.stencilBits != FramebufferConfig::ATTR_DONT_CARE)
        ADD_ATTR2(NSOpenGLPFAStencilSize, pixelFormatAttrs.stencilBits);

    if (pixelFormatAttrs.stereo)
        ADD_ATTR(NSOpenGLPFAStereo);

    if (pixelFormatAttrs.doublebuffer)
        ADD_ATTR(NSOpenGLPFADoubleBuffer);

    if (pixelFormatAttrs.samples != FramebufferConfig::ATTR_DONT_CARE)
    {
        if (pixelFormatAttrs.samples == 0)
        {
            ADD_ATTR2(NSOpenGLPFASampleBuffers, 0);
        }
        else
        {
            ADD_ATTR2(NSOpenGLPFASampleBuffers, 1);
            ADD_ATTR2(NSOpenGLPFASamples, pixelFormatAttrs.samples);
        }
    }

    // NOTE: All NSOpenGLPixelFormats on the relevant cards support sRGB
    //       framebuffer, so there's no need (and no way) to request it

    ADD_ATTR(0);

#undef ADD_ATTR
#undef ADD_ATTR2

    _pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];


    if (_pixelFormat == nil) {
        throw std::runtime_error("NSGL: Failed to find a suitable pixel format");
    }

    // Never share the OpenGL context for offscreen rendering
    NSOpenGLContext* share = NULL;
    _object = [[NSOpenGLContext alloc] initWithFormat:_pixelFormat shareContext:share];

    if (_object == nil) {
        throw std::runtime_error("NSGL: Failed to create OpenGL context");
    }

    //[_object setView:window->ns.view];
#endif
}


void
OSGLContext_mac::getGPUInfos(std::list<OpenGLRendererInfo>& renderers)
{
    CGLContextObj curr_ctx = 0;
    curr_ctx = CGLGetCurrentContext (); // get current CGL context

    CGLRendererInfoObj rend;
    GLint nrend = 0;
    CGLQueryRendererInfo(0xffffffff, &rend, &nrend);
    for (GLint i = 0; i < nrend; ++i) {

        OpenGLRendererInfo info;

        GLint rendererID,haccelerated;
        if (CGLDescribeRenderer(rend, i,  kCGLRPRendererID, &rendererID) != kCGLNoError) {
            continue;
        }
        CGLDescribeRenderer(rend, i,  kCGLRPAccelerated, &haccelerated);

        // We don't allow renderers that are not hardware accelerated
        if (!haccelerated) {
            continue;
        }

        info.rendererID = rendererID;

#if !defined(MAC_OS_X_VERSION_10_7) || \
MAC_OS_X_VERSION_MAX_ALLOWED < MAC_OS_X_VERSION_10_7
        GLint nBytesMem,nBytesTexMem;
        CGLDescribeRenderer(rend, i,  kCGLRPVideoMemory, &nBytesMem);
        CGLDescribeRenderer(rend, i,  kCGLRPTextureMemory, &nBytesTexMem);

        info.maxMemBytes = (std::size_t)nBytesMem;
        info.maxTexMemBytes = (std::size_t)nBytesTexMem;
#else
        //Available in OS X v10.0 and later.
        //Deprecated in OS X v10.7.
        GLint nMBMem,nMBTexMem;
        CGLDescribeRenderer(rend, i,  kCGLRPVideoMemoryMegabytes, &nMBMem);
        CGLDescribeRenderer(rend, i,  kCGLRPTextureMemoryMegabytes, &nMBTexMem);

        info.maxMemBytes = (std::size_t)nMBMem * 1e6;
        info.maxTexMemBytes = (std::size_t)nMBTexMem * 1e6;

        // Available in OS X v10.9
        //GLint maxOpenGLMajorVersion;
        //CGLDescribeRenderer(rend, i,  kCGLRPMajorGLVersion, &maxOpenGLMajorVersion);

#endif
        /*GLint fragCapable, clCapable
        CGLDescribeRenderer(rend, i,  kCGLRPGPUFragProcCapable, &fragCapable);
        CGLDescribeRenderer(rend, i,  kCGLRPAcceleratedCompute, &clCapable);*/
        //info.fragCapable = (bool)fragCapable;
        //info.clCapable = (bool)clCapable;




        // Create a dummy OpenGL context for that specific renderer to retrieve more infos
        // See https://developer.apple.com/library/mac/technotes/tn2080/_index.html
        std::vector<CGLPixelFormatAttribute> attributes;
        makeAttribsFromFBConfig(FramebufferConfig(), GLVersion.major, GLVersion.minor, false, rendererID, attributes);
        CGLPixelFormatObj pixelFormat;
        GLint numPixelFormats;
        CGLError errorCode = CGLChoosePixelFormat(&attributes[0], &pixelFormat, &numPixelFormats);
        if (errorCode != kCGLNoError) {
            qDebug() << "Failed to created pixel format for renderer " << rendererID;
            continue;
        }
        CGLContextObj cglContext;
        errorCode = CGLCreateContext(pixelFormat, 0, &cglContext);
        CGLDestroyPixelFormat (pixelFormat);
        if (errorCode != kCGLNoError) {
            qDebug() << "Failed to create OpenGL context for renderer " << rendererID;
            continue;
        }
        errorCode = CGLSetCurrentContext (cglContext);
        if (errorCode != kCGLNoError) {
            qDebug() << "Failed to make OpenGL context current for renderer " << rendererID;
            continue;
        }
        // get renderer strings
        info.rendererName = std::string((char*)glGetString (GL_RENDERER));
        info.vendorName = std::string((char*)glGetString (GL_VENDOR));
        info.glVersionString = std::string((char*)glGetString (GL_VERSION));
        //std::string strExt((char*)glGetString (GL_EXTENSIONS));

        glGetIntegerv (GL_MAX_TEXTURE_SIZE,
                       &info.maxTextureSize);

        CGLDestroyContext (cglContext);

        renderers.push_back(info);
    }


    CGLDestroyRendererInfo(rend);
    if (curr_ctx) {
        CGLSetCurrentContext (curr_ctx); // reset current CGL context
    }
}

void
OSGLContext_mac::makeContextCurrent(const OSGLContext_mac* context)
{
    /*if (context) {
        [context->_object makeCurrentContext];
    } else {
        [NSOpenGLContext clearCurrentContext];
    }*/
    if (context) {
        CGLSetCurrentContext(context->_context);
    } else {
        CGLSetCurrentContext(0);
    }
}

void
OSGLContext_mac::swapBuffers()
{
 //   [_object flushBuffer];
    CGLFlushDrawable(_context);
}

void
OSGLContext_mac::swapInterval(int interval)
{
    /*GLint sync = interval;
    [_object setValues:&sync forParameter:NSOpenGLCPSwapInterval];*/
    GLint value = interval;
    CGLSetParameter(_context, kCGLCPSwapInterval, &value);
}

OSGLContext_mac::~OSGLContext_mac()
{
    CGLDestroyContext(_context);
    _context = 0;
    /*[_pixelFormat release];
    _pixelFormat = nil;

    [_object release];
    _object = nil;*/
}

NATRON_NAMESPACE_EXIT;

#endif // __NATRON_OSX__