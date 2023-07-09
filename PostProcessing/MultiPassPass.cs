using System.Collections.Generic;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class MultiPassPass : ScriptableRenderPass
{
    private List<ShaderTagId> m_Tags;
    public MultiPassPass(List<string> lightModePasses)
    {
        m_Tags =new List<ShaderTagId>();
        foreach (var pass in lightModePasses)
        {
            m_Tags.Add(new ShaderTagId(pass));
        }

        this.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        FilteringSettings filteringSettings = FilteringSettings.defaultValue;

        foreach (var pass in m_Tags)
        {
            DrawingSettings drawingSettings = CreateDrawingSettings(pass, ref renderingData, SortingCriteria.CommonOpaque);
            context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);
        }

        context.Submit();
    }
}