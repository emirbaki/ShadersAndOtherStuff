using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomPostProcessRenderFeature : ScriptableRendererFeature
{
    [SerializeField]
    private Shader m_bloomShader;
    [SerializeField]
    private Shader m_compositeShader;

    private Material m_bloomMaterial;
    private Material m_compositeMaterial;


    private CustomPostProcessPass m_customPass;

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (renderingData.cameraData.cameraType == CameraType.Game)
        {
            renderer.EnqueuePass(m_customPass);
        }
    }

    public override void Create()
    {
        m_bloomMaterial = CoreUtils.CreateEngineMaterial(m_bloomShader);
        m_compositeMaterial = CoreUtils.CreateEngineMaterial(m_compositeShader);

        m_customPass = new CustomPostProcessPass(m_bloomMaterial, m_compositeMaterial);
    }
    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
    {
        if(renderingData.cameraData.cameraType == CameraType.Game)
        {
            m_customPass.ConfigureInput(ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Color);
            m_customPass.SetTarget(renderer.cameraColorTargetHandle, renderer.cameraDepthTargetHandle);

        }
    }
    protected override void Dispose(bool disposing)
    {
        CoreUtils.Destroy(m_bloomMaterial);
        CoreUtils.Destroy(m_compositeMaterial);
    }
}
