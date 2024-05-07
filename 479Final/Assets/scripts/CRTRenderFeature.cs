using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CRTRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class TextureSettings
    {
        public RenderTextureFormat colorFormat = RenderTextureFormat.ARGB32;
        public int depthBufferBits = 0;  // Typically 0 if not using depth
    }

    public class CRTRenderPass : ScriptableRenderPass
    {
        private RenderTargetHandle temporaryRT;
        private Material crtMaterial;
        private TextureSettings settings;
        public CRTRenderPass(RenderPassEvent passEvent, TextureSettings settings, Material material)
        {
            this.renderPassEvent = passEvent;
            this.crtMaterial = material;
            this.settings = settings;
            temporaryRT.Init("_TemporaryCRTTexture");
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            cameraTextureDescriptor.colorFormat = settings.colorFormat;
            cameraTextureDescriptor.depthBufferBits = settings.depthBufferBits;
            cmd.GetTemporaryRT(temporaryRT.id, cameraTextureDescriptor, FilterMode.Bilinear);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get("CRT Effect");

            if (crtMaterial == null)
            {
                Debug.LogError("CRT material not found.");
                return;
            }

            // Use the temporary render texture for the CRT effect
            Blit(cmd, renderingData.cameraData.renderer.cameraColorTarget, temporaryRT.Identifier(), crtMaterial);
            Blit(cmd, temporaryRT.Identifier(), renderingData.cameraData.renderer.cameraColorTarget);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            if (temporaryRT.id != -1)
            {
                cmd.ReleaseTemporaryRT(temporaryRT.id);
            }
        }
    }

    [SerializeField]
    private RenderPassEvent passEvent = RenderPassEvent.AfterRenderingOpaques;
    [SerializeField]
    private TextureSettings textureSettings = new TextureSettings();
    [SerializeField]
    private Material crtMaterial;

    private CRTRenderPass crtPass;

    public override void Create()
    {
        crtPass = new CRTRenderPass(passEvent, textureSettings, crtMaterial);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (crtPass == null)
            return;

        renderer.EnqueuePass(crtPass);
    }
}
